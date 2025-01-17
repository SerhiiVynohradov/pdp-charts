class CreateInvoices < ActiveRecord::Migration[7.2]
  def change
    create_table :invoices do |t|
      t.references :invoiceable, polymorphic: true, index: true
      t.string  :number                # e.g., "INV-2025-0001"
      t.decimal :amount, precision: 10, scale: 2  # e.g. 199.99
      t.string  :currency, default: "USD"
      t.date    :issue_date
      t.date    :due_date
      t.string  :status, default: "unpaid"  # e.g. "paid", "overdue"
      t.text    :notes

      t.timestamps
    end
  end
end
