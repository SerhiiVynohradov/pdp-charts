module Superadmin
  class InvoicesController < ApplicationController
    before_action :set_invoiceable
    before_action :set_invoice, only: [:show, :edit, :update, :destroy]

    def index
      @invoices = @invoiceable.invoices.order(created_at: :desc)
    end

    def show
    end

    def new
      @invoice = @invoiceable.invoices.build
    end

    def create
      @invoice = @invoiceable.invoices.build(invoice_params)
      if @invoice.save
        redirect_to superadmin_payer_invoices_path(@invoiceable, invoiceable_type: invoiceable_class),
          notice: "Invoice created."
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @invoice.update(invoice_params)
        redirect_to superadmin_payer_invoices_path(@invoiceable, invoiceable_type: invoiceable_class),
          notice: "Invoice updated."
      else
        render :edit
      end
    end

    def destroy
      @invoice.destroy
      redirect_to superadmin_payer_invoices_path(@invoiceable, invoiceable_type: invoiceable_class),
        alert: "Invoice deleted."
    end

    private

    # 1) Figure out which model: "User" or "Company"
    def set_invoiceable
      type = params[:invoiceable_type] # "User" or "Company"
      # safe-guard: only allow "User" or "Company"
      unless ["User", "Company"].include?(type)
        raise ActiveRecord::RecordNotFound, "Unknown invoiceable_type: #{type}"
      end

      @invoiceable = type.constantize.find(params[:payer_id])
    end

    # 2) Load specific invoice (through the polymorphic association)
    def set_invoice
      @invoice = @invoiceable.invoices.find(params[:id])
    end

    # 3) Permit invoice fields
    def invoice_params
      params.require(:invoice).permit(
        :number,
        :amount,
        :currency,
        :issue_date,
        :due_date,
        :status,
        :notes
      )
    end

    # Helper to pass the correct invoiceable_type back to the routes
    def invoiceable_class
      params[:invoiceable_type]
    end
  end
end
