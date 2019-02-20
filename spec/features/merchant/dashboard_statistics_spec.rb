require 'rails_helper'

RSpec.describe 'merchant dashboard statistics' do
  before :each do
    u1 = create(:user, state: "CO", city: "Fairfield")
    u2 = create(:user, state: "OK", city: "OKC")
    u3 = create(:user, state: "IA", city: "Fairfield")
    u4 = create(:user, state: "IA", city: "Des Moines")
    u5 = create(:user, state: "IA", city: "Des Moines")
    u6 = create(:user, state: "IA", city: "Des Moines")
    @m1 = create(:merchant)
    @m2 = create(:merchant)
    @i1 = create(:item, merchant_id: @m1.id, inventory: 20)
    @i2 = create(:item, merchant_id: @m1.id, inventory: 20)
    @i3 = create(:item, merchant_id: @m1.id, inventory: 20)
    @i4 = create(:item, merchant_id: @m1.id, inventory: 20)
    @i5 = create(:item, merchant_id: @m1.id, inventory: 20)
    @i6 = create(:item, merchant_id: @m1.id, inventory: 20)
    @i7 = create(:item, merchant_id: @m1.id, inventory: 20)
    @i9 = create(:item, merchant_id: @m1.id, inventory: 20)
    @i8 = create(:item, merchant_id: @m2.id, inventory: 20)
    o1 = create(:completed_order, user: u1)
    o2 = create(:completed_order, user: u2)
    o3 = create(:completed_order, user: u3)
    o4 = create(:completed_order, user: u1)
    o5 = create(:cancelled_order, user: u5)
    o6 = create(:completed_order, user: u6)
    @oi1 = create(:order_item, item: @i1, order: o1, quantity: 2, created_at: 1.days.ago)
    @oi2 = create(:order_item, item: @i2, order: o2, quantity: 7, created_at: 7.days.ago)
    @oi3 = create(:order_item, item: @i2, order: o3, quantity: 7, created_at: 7.days.ago)
    @oi4 = create(:order_item, item: @i3, order: o3, quantity: 4, created_at: 6.days.ago)
    @oi5 = create(:order_item, item: @i4, order: o4, quantity: 3, created_at: 4.days.ago)
    @oi6 = create(:order_item, item: @i5, order: o5, quantity: 1, created_at: 5.days.ago)
    @oi7 = create(:order_item, item: @i6, order: o6, quantity: 2, created_at: 3.days.ago)
    @oi1.fulfill
    @oi2.fulfill
    @oi3.fulfill
    @oi4.fulfill
    @oi5.fulfill
    @oi6.fulfill
    @oi7.fulfill

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m1)
    visit dashboard_path
  end

  it 'shows top items sold by quantity' do
    within("#top-items-sold-by-quantity") do
      expect(page.all('li')[0]).to have_content("#{@i2.name}: 14")
      expect(page.all('li')[1]).to have_content("#{@i3.name}: 4")
      expect(page.all('li')[2]).to have_content("#{@i4.name}: 3")
      expect(page.all('li')[3]).to have_content("#{@i1.name}: 2")
      expect(page.all('li')[4]).to have_content("#{@i6.name}: 2")
    end
  end

  it 'shows percent of items sold' do
    within("#percent-of-items-sold") do
      expect(page).to have_content("You have sold 26 items, 19.4% of your total inventory")
    end
  end
end