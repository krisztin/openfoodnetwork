# frozen_string_literal: true

module Reporting
  class FrontendData
    def initialize(current_user)
      @current_user = current_user
    end

    # Load managed distributor enterprises of current user
    def distributors
      @distributors ||= Enterprise.is_distributor.managed_by(current_user)
    end

    def suppliers
      @suppliers ||= my_suppliers | suppliers_of_products_distributed_by(distributors)
    end

    # Load managed producer enterprises of current user
    def my_suppliers
      Enterprise.is_primary_producer.managed_by(current_user)
    end

    def suppliers_of_products_distributed_by(distributors)
      supplier_ids = Spree::Product.in_distributors(distributors.select('enterprises.id')).
        select('spree_products.supplier_id')

      Enterprise.where(id: supplier_ids)
    end

    def orders_distributors
      @orders_distributors ||= permissions.visible_enterprises_for_order_reports
        .is_distributor.select("enterprises.id, enterprises.name")
    end

    def orders_suppliers
      @orders_suppliers ||= permissions.visible_enterprises_for_order_reports
        .is_primary_producer.select("enterprises.id, enterprises.name")
    end

    def order_cycles
      @order_cycles ||= OrderCycle.
        active_or_complete.
        visible_by(current_user).
        order('order_cycles.orders_close_at DESC')
    end

    private

    attr_reader :current_user

    def permissions
      @permissions ||= OpenFoodNetwork::Permissions.new(current_user)
    end
  end
end
