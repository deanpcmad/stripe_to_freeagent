require "freeagent"
require "stripe"
require "csv"

task run: :environment do
	u = User.first
	f = u.freeagent_accounts.first
	s = u.stripe_accounts.first

	FreeAgent.access_details ENV["FREEAGENT_ID"], ENV["FREEAGENT_SECRET"], f.token

	# get company to check it's authenticated
	FreeAgent::Company.information


	# stripe
	Stripe.api_key = s.token


	# FreeAgent::BankTransaction.new bank_account: f.main, description: "Invoice #22 - Dean Perry", amount: "20.00"

	# CSV.open("transactions.csv", "wb") do |csv|
	#   Stripe::Charge.all.each do |charge|
	#     csv << [Time.at(charge.created).strftime("%d/%m/%Y"), charge.amount / 100.0, charge.description || charge.id] if charge.paid
	#   end
	#   Stripe::Transfer.all.each do |transfer|
	#     transfer.transactions.each do | transaction|
	#       csv << [Time.at(transaction.created).strftime("%d/%m/%Y"), transaction.amount / 100.0, transaction.description || transaction.id]
	#       csv << [Time.at(transaction.created).strftime("%d/%m/%Y"), - (transaction.fee / 100.0), "Stripe Fee = #{transaction.id}"]
	#     end
	#   end
	# end

	# FreeAgent::BankTransaction.upload_statement File.open("transactions.csv"), f.main


	CSV.open("balances.csv", "wb") do |csv|
	  Stripe::BalanceTransaction.all.each do |b|
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

	FreeAgent::BankTransaction.upload_statement File.open("balances.csv"), f.stripe

	explain = FreeAgent::BankTransaction.unexplained f.stripe

	puts "Found #{explain.count} unexplained transactions"

	explain.each do |e|
	  puts "Explaining FreeAgent bank transction #{e.id}..."
	  if e.description.match(/stripe_fee/)
	    # The transaction is a fee 
	    FreeAgent::BankTransactionExplanation.create_for_transaction e.url, e.dated_on, "Stripe Charge", e.unexplained_amount, "363"
	    puts "  - Explained as a Stripe Charge"
	  elsif e.description.match(/transfer/)
	    FreeAgent::BankTransactionExplanation.create_transfer e.url, e.dated_on, e.unexplained_amount, f.main
	    puts "  - Explained as a Transfer"
	  else
	    FreeAgent::BankTransactionExplanation.create_for_transaction e.url, e.dated_on, e.description.gsub("//OTHER/", ""), e.unexplained_amount, "001"
	    puts "  - Explained as a Sale"
	  end
	end

	puts "Successfully explained #{explain.count} transactions"
end