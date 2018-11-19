module Admin
  class TenantsController < Admin::BaseController
    before_action :set_tenant, only: [:edit, :update, :destroy]
    before_action :tenant_enabled

    def index
      @tenants = Tenant.all
    end

    def new
      @tenant = Tenant.new
    end

    def create
      @tenant = Tenant.new(tenant_params)
      if @tenant.save
        Apartment::Tenant.create(@tenant.name)
        redirect_to admin_tenants_path, notice: t(:tenant_was_created)
      else
        render :new
      end
    end

    def edit; end

    def update
      if @tenant.update_attributes(tenant_params)
        redirect_to admin_tenants_path, notice: t(:tenant_was_updated)
      else
        render 'edit'
      end
    end

    def destroy
      begin
        Apartment::Tenant.drop(@tenant.name)
      rescue => e
        logger.warn(e)
      end
      @tenant.destroy
      redirect_to admin_tenants_path, notice: t(:tenant_was_deleted)
    end

    private

      def set_tenant
        @tenant = Tenant.find(params[:id])
      end

      def tenant_params
        params.require(:tenant).permit(:name)
      end

      def tenant_enabled
        p Rails.application.config.database_configuration[Rails.env]['adapter']
        unless Rails.application.config.database_configuration[Rails.env]['adapter'] == 'mysql2'
          return redirect_to admin_dashboard_path, notice: t(:cannot_access_to_tenant)
        end
        current = Tenant.connection.current_database
        unless Tenant.find_by(name: current).nil?
          redirect_to admin_dashboard_path, notice: t(:cannot_access_to_tenant)
        end
      end
  end
end
