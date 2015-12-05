shopProducts = [
  { id: "e1", name: "elote chico", price: 15.00 },
  { id: "e2", name: "elote mediano", price: 20.00 },
  { id: "e3", name: "elote grande", price: 25.00 }
]

describe "Update item count", ->
  describe "increment", ->
    it "updates the item count", ->
      shop = Shop.new(shopProducts)
      shop = Shop.addToOrder(shop, "e1")
      shop = Shop.incrementCountInOrder(shop, "e1")
      shop = Shop.incrementCountInOrder(shop, "e1")
      item = _.first shop.currentOrder.items
      expect(item.count).toEqual 3

    it "updates the item total", ->
      shop = Shop.new(shopProducts)
      shop = Shop.addToOrder(shop, "e1")
      shop = Shop.incrementCountInOrder(shop, "e1")
      shop = Shop.incrementCountInOrder(shop, "e1")
      item = _.first shop.currentOrder.items
      expect(item.total).toEqual 45.00

    it "updates the order total", ->
      shop = Shop.new(shopProducts)
      shop = Shop.addToOrder(shop, "e1")
      shop = Shop.incrementCountInOrder(shop, "e1")
      shop = Shop.incrementCountInOrder(shop, "e1")
      expect(shop.currentOrder.total).toEqual 45.00

  describe "decrement", ->
    it "updates the item count", ->
      shop = Shop.new(shopProducts)
      shop = Shop.addToOrder(shop, "e1")
      shop = Shop.incrementCountInOrder(shop, "e1")
      shop = Shop.decrementCountInOrder(shop, "e1")
      item = _.first shop.currentOrder.items
      expect(item.count).toEqual 1

    it "updates the item total", ->
      shop = Shop.new(shopProducts)
      shop = Shop.addToOrder(shop, "e1")
      shop = Shop.incrementCountInOrder(shop, "e1")
      shop = Shop.decrementCountInOrder(shop, "e1")
      item = _.first shop.currentOrder.items
      expect(item.total).toEqual 15.00

    it "updates the order total", ->
      shop = Shop.new(shopProducts)
      shop = Shop.addToOrder(shop, "e1")
      shop = Shop.incrementCountInOrder(shop, "e1")
      shop = Shop.decrementCountInOrder(shop, "e1")
      expect(shop.currentOrder.total).toEqual 15.00

    it "removes the item if the count goes to 0", ->
      shop = Shop.new(shopProducts)
      shop = Shop.addToOrder(shop, "e1")
      shop = Shop.incrementCountInOrder(shop, "e1")
      shop = Shop.decrementCountInOrder(shop, "e1")
      shop = Shop.decrementCountInOrder(shop, "e1")
      expect(shop.currentOrder.items).toEqual []

  it "mantains items order after increment/decrement order", ->
    shop = Shop.new(shopProducts)
    shop = Shop.addToOrder(shop, "e1")
    shop = Shop.addToOrder(shop, "e2")
    shop = Shop.incrementCountInOrder(shop, "e1")
    shop = Shop.decrementCountInOrder(shop, "e1")
    expect(_.map shop.currentOrder.items, (item) -> item.productId).toEqual ["e1", "e2"]
