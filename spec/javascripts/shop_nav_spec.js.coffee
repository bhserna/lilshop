describe "Shop navigation", ->
  it "shows products by default", ->
    shop = Shop.new()
    expect(shop.currentPage).toEqual "products"

  it "can go to the current order", ->
    shop = Shop.new()
    shop = Shop.changePage(shop, "currentOrder")
    expect(shop.currentPage).toEqual "currentOrder"

  it "can go to the order", ->
    shop = Shop.new()
    shop = Shop.changePage(shop, "todayOrders")
    expect(shop.currentPage).toEqual "todayOrders"
