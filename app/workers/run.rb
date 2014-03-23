require "freeagent"
require "stripe"
require "csv"

class Run

	@queue = :run

  def self.perform(user_id)
  	u = User.find(user_id)
  	f = u.freeagent_account
  	s = u.stripe_account

  	l = u.logs.build
  	l.content = ""
  	l.content += "Starting import for User #{u.id}\n"

  	FreeAgent.access_details ENV["FREEAGENT_ID"], ENV["FREEAGENT_SECRET"], f.token

  	# get company to check it's authenticated
  	l.content += "FreeAgent Company: #{FreeAgent::Company.information.name}\n"

  	# stripe
  	Stripe.api_key = s.token

  	l.content += "Getting Stripe Balance Transactions...\n"

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

  	l.content += "Uploading Stripe Balance Transactions to FreeAgent account #{f.stripe}...\n"

  	s.last_updated = DateTime.now
  	s.save

  	FreeAgent::BankTransaction.upload_statement File.open("balances.csv"), f.stripe

  	l.content += "Uploaded Transactions\n"

  	# Sleep for 5 seconds
  	sleep 5

  	explain = FreeAgent::BankTransaction.unexplained f.stripe

  	l.content += "Found #{explain.count} unexplained transactions\n"

  	explain.each do |e|
  	  l.content += "Explaining FreeAgent bank transction #{e.id}...\n"
  	  if e.description.match(/stripe_fee/)
  	    # The transaction is a fee 
  	    FreeAgent::BankTransactionExplanation.create_for_transaction e.url, e.dated_on, "Stripe Charge", e.unexplained_amount, "363"
  	    l.content += "  - Explained as a Stripe Charge\n"
  	  elsif e.description.match(/transfer/)
  	    FreeAgent::BankTransactionExplanation.create_transfer e.url, e.dated_on, e.unexplained_amount, f.main
  	    l.content += "  - Explained as a Transfer\n"
  	  else
  	    FreeAgent::BankTransactionExplanation.create_for_transaction e.url, e.dated_on, e.description.gsub("//OTHER/", ""), e.unexplained_amount, "001"
  	    l.content += "  - Explained as a Sale\n"
  	  end
  	end

  	l.content += "...\n"
  	l.content += "Successfully explained #{explain.count} transactions\n"

  	l.content += "Complete\n"
  	l.success = true
  	l.save

  rescue
  	l.content += "\n\nERROR\n\n"
  	l.success = false
  	l.save
  end

end