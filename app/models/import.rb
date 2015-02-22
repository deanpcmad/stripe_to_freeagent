class Import < ActiveRecord::Base

  belongs_to :user
  belongs_to :stripe_account
  belongs_to :freeagent_account

  before_validation :generate_token, unless: Proc.new { |model| model.persisted? }

  def run_import!
    require "freeagent"
    require "stripe"
    require "csv"

    i = self
    f = i.freeagent_account
    s = i.stripe_account

    i.started_at = DateTime.now
    i.log += "Starting import...\n"
    i.log += "Started at #{i.started_at}\n"
    i.save

    # Refresh the FreeAgent token if it's expired
    if f.token_expired?
      f.refresh_token!
    end

    FreeAgent.access_details ENV["FREEAGENT_ID"], ENV["FREEAGENT_SECRET"], f.token

    # get company to check it's authenticated
    i.log += "FreeAgent Company: #{FreeAgent::Company.information.name}\n"
    i.save

    # stripe
    Stripe.api_key = s.token

    i.log += "Getting Stripe Balance Transactions...\n"
    i.save

    CSV.open("balances.csv", "wb") do |csv|
      Stripe::BalanceTransaction.all(count: 100, available_on: {gte: s.import_from.to_i}).each do |b|
        if b.type == "transfer"
          csv << [Time.at(b.available_on).strftime("%d/%m/%Y"), (b.amount / 100.0), "transfer"]
        elsif b.type == "charge"
          if b.fee > 0
            # Create the charge
            csv << [Time.at(b.available_on).strftime("%d/%m/%Y"), (b.amount / 100.0), (b.description || b.source)]
            # Create the fee for that charge
            csv << [Time.at(b.available_on).strftime("%d/%m/%Y"), -(b.fee / 100.0), "stripe_fee"]
          else
            # nothing
          end
        end
      end
    end

    bt_count = Stripe::BalanceTransaction.all(count: 100, available_on: {gte: s.import_from.to_i}).count

    i.log += "Found #{bt_count} Stripe Balance Transactions...\n"
    i.save

    if bt_count == 0
      i.log += "Found no Stripe Balance Transactions so stopping import...\n"
      i.save

      i.finished_at = DateTime.now
      i.success = true
      i.save
    else

      i.log += "Uploading Stripe Balance Transactions to FreeAgent account #{f.stripe}...\n"
      i.save

      s.last_updated = DateTime.now
      s.save

      FreeAgent::BankTransaction.upload_statement File.open("balances.csv"), f.stripe

      i.log += "Uploaded Transactions\n"
      i.save

      # Sleep for 5 seconds
      sleep 5

      explain = FreeAgent::BankTransaction.unexplained f.stripe

      i.log += "Found #{explain.count} unexplained transactions\n"
      i.save

      explain.each do |e|
        i.log += "Explaining FreeAgent bank transction #{e.id}...\n"
        i.save
        if e.description.match(/stripe_fee/)
          # The transaction is a fee 
          FreeAgent::BankTransactionExplanation.create_for_transaction e.url, e.dated_on, "Stripe Charge", e.unexplained_amount, "363"
          i.log += "  - Explained as a Stripe Charge\n"
          i.save
        elsif e.description.match(/transfer/)
          FreeAgent::BankTransactionExplanation.create_transfer e.url, e.dated_on, e.unexplained_amount, f.main
          i.log += "  - Explained as a Transfer\n"
          i.save
        else
          FreeAgent::BankTransactionExplanation.create_for_transaction e.url, e.dated_on, e.description.gsub("//OTHER/", ""), e.unexplained_amount, "001"
          i.log += "  - Explained as a Sale\n"
          i.save
        end
      end

      i.log += "...\n"
      i.save
      i.log += "Successfully explained #{explain.count} transactions\n"
      i.save

      i.log += "Complete\n"
      i.finished_at = DateTime.now
      i.success = true
      i.save
    end

    # s.import_from = DateTime.now
    # s.save
  end

  private

  def generate_token
    self.token = SecureRandom.uuid
  end

end