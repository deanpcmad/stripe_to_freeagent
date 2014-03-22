require "freeagent"
require "stripe"
require "csv"

u = User.first
f = u.freeagent_accounts.first
s = u.stripe_accounts.first

FreeAgent.access_details f.token, f.refresh_token

fa = FreeAgent::Client.new f.token, f.refresh_token
fa.access_token = f.token

# get company to check it's authenticated
fa.get("company")
# FreeAgent::Company.information




# stripe
Stripe.api_key = s.token
charges = Stripe::Charge.all


# FreeAgent::BankTransaction.new bank_account: f.main, description: "Invoice #22 - Dean Perry", amount: "20.00"

CSV.open("transactions.csv", "wb") do |csv|
  Stripe::Charge.all.each do |charge|
    if charge.paid
      csv << [Time.at(charge.created).strftime("%d/%m/%Y"), charge.amount / 100.0, charge.description || charge.id]
    end
  end
  Stripe::Transfer.all.each do |transfer|
    transfer.transactions.each do | transaction|
      csv << [Time.at(transaction.created).strftime("%d/%m/%Y"), transaction.amount / 100.0, transaction.description || transaction.id]
      csv << [Time.at(transaction.created).strftime("%d/%m/%Y"), - (transaction.fee / 100.0), "Stripe Fee = #{transaction.id]
    end
  end
end

FreeAgent::BankTransaction.upload_statement File.open("transactions.csv"), f.main, fa.access_token.token


CSV.open("balances.csv", "wb") do |csv|
  Stripe::BalanceTransaction.all.each do |b|
    if b.type == "transfer"
      csv << [Time.at(b.created).strftime("%d/%m/%Y"), (b.amount / 100.0), "Transfer"]
    elsif b.type == "charge"
      if b.fee > 0
        # Create the charge
        csv << [Time.at(b.created).strftime("%d/%m/%Y"), (b.amount / 100.0), (b.description || b.source)]
        # Create the fee for that charge
        csv << [Time.at(b.created).strftime("%d/%m/%Y"), -(b.fee / 100.0), "Stripe Fee"]
      else
        # nothing
      end
    end
  end
end

FreeAgent::BankTransaction.upload_statement File.open("balances.csv"), f.main, fa.access_token.token

expl = FreeAgent::BankTransactionExplanation.find_all_by_bank_account f.main