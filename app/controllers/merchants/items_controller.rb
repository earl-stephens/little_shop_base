class Merchants::ItemsController < ApplicationController
  before_action :merchant_or_admin, only: [:index]

  def index
    @items = Item.where(user: current_user)
    # binding.pry
    @no_default_pics_present = Item.no_default_pics_present?
    @no_pic_items = Item.only_default_pics
    @num_unfulfilled_orders = OrderItem.number_of_unfulfilled_orders
    @impact_on_revenue = OrderItem.revenue_impact
  end

  def enable
    set_item_active(true)
  end

  def disable
    set_item_active(false)
  end

  def destroy
    @item = Item.find(params[:id])
    merchant = @item.user
    if @item && @item.ever_ordered?
      flash[:error] = "Attempt to delete #{@item.name} was thwarted!"
    elsif @item
      @item.destroy
    end
    if current_admin?
      redirect_to admin_merchant_items_path(merchant)
    else
      redirect_to dashboard_items_path
    end
  end

  def new
    @item = Item.new
    @form_path = [:dashboard, @item]
  end

  def edit
    @item = Item.find(params[:id])
    @form_path = [:dashboard, @item]
  end

  def create
    ip = item_params
    if ip[:image].empty?
      ip[:image] = 'https://picsum.photos/200/300/?image=524'
    end
    ip[:active] = true
    @merchant = current_user
    if current_admin?
      @merchant = User.find(params[:merchant_id])
    end
    @item = @merchant.items.create(ip)
    if @item.save
      flash[:success] = "#{@item.name} has been added!"
      if current_admin?
        redirect_to admin_merchant_items_path(@merchant)
      else
        redirect_to dashboard_items_path
      end
    else
      if current_admin?
        @form_path = [:admin, @merchant, @item]
      else
        @form_path = [:dashboard, @item]
      end
      render :new
    end
  end

  def update
    @merchant = current_user
    if current_admin?
      @merchant = User.find(params[:merchant_id])
    end
    @item = Item.find(params[:id])

    ip = item_params
    if ip[:image].empty?
      ip[:image] = 'https://picsum.photos/200/300/?image=524'
    end
    ip[:active] = true
    @item.update(ip)
    if @item.save
      flash[:success] = "#{@item.name} has been updated!"
      if current_admin?
        redirect_to admin_merchant_items_path(@merchant)
      else
        redirect_to dashboard_items_path
      end
    else
      if current_admin?
        @form_path = [:admin, @merchant, @item]
      else
        @form_path = [:dashboard, @item]
      end
      render :edit
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :image, :price, :inventory)
  end

  def set_item_active(state)
    item = Item.find(params[:id])
    item.active = state
    item.save
    if current_admin?
      redirect_to admin_merchant_items_path(item.user)
    else
      redirect_to dashboard_items_path
    end
  end
end
