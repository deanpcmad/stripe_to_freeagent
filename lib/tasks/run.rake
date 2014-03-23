require "freeagent"
require "stripe"
require "csv"
require "colorize"

task run: :environment do
	u = User.first
	f = u.freeagent_accounts.first
	s = u.stripe_accounts.first

	FreeAgent.access_details ENV["FREEAGENT_ID"], ENV["FREEAGENT_SECRET"], f.token

	# get company to check it's authenticated
	FreeAgent::Company.information

	# stripe
	Stripe.api_key = s.token

	puts "Getting Stripe Balance Transactions..."

	CSV.open("balances.csv", "wb") do |csv|
	  Stripe::BalanceTransaction.all(count: 100, available_on: {gte: s.last_updated.to_i}).each do |b|
	    if b.type == "transfer"
	      csv << [Time.at(b.created).strftime("%d/%m/%Y"), (b.amount / 100.0), "transfer"]
	    elsif b.type == "charge"
	      if b.fee > 0
	        # Create the charge
	        csv << [Time.at(b.created).strftime("%d/%m/%Y"), (b.amount / 100.0), (b.description || b.source)]
	        # Create the fee for that charge
	        csv << [Time.at(b.created).strftime("%d/%m/%Y"), -(b.fee / 100.0), "stripe_fee"]
	      else
	        # nothing
	      end
	    end
	  end
	end

	puts "Uploading Stripe Balance Transactions to FreeAgent account #{f.stripe}..."

	s.last_updated = DateTime.now
	s.save

	FreeAgent::BankTransaction.upload_statement File.open("balances.csv"), f.stripe

	puts "Uploaded Transactions".green

	# Sleep for 5 seconds
	sleep 5

	explain = FreeAgent::BankTransaction.unexplained f.stripe

	puts "Found #{explain.count} unexplained transactions"

	explain.each do |e|
	  puts "Explaining FreeAgent bank transction #{e.id}...".yellow
	  if e.description.match(/stripe_fee/)
	    # The transaction is a fee 
	    FreeAgent::BankTransactionExplanation.create_for_transaction e.url, e.dated_on, "Stripe Charge", e.unexplained_amount, "363"
	    puts "  - Explained as a Stripe Charge".green
	  elsif e.description.match(/transfer/)
	    FreeAgent::BankTransactionExplanation.create_transfer e.url, e.dated_on, e.unexplained_amount, f.main
	    puts "  - Explained as a Transfer".green
	  else
	    FreeAgent::BankTransactionExplanation.create_for_transaction e.url, e.dated_on, e.description.gsub("//OTHER/", ""), e.unexplained_amount, "001"
	    puts "  - Explained as a Sale".green
	  end
	end

	puts "..."
	puts "Successfully explained #{explain.count} transactions".green
end