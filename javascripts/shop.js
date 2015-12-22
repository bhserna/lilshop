(function() {
  var Dict, Item, LocalStore, Order, Products, loadState, onAction, shopProducts, updateState;

  Dict = {
    update: function(object, props) {
      return _.extend({}, object, props);
    }
  };

  window.Time = {
    now: function() {
      return moment().format();
    },
    utc: function() {
      return moment.utc().format();
    }
  };

  LocalStore = {
    save: function(state) {
      return localStorage.shop = JSON.stringify(state);
    },
    load: function() {
      return JSON.parse(localStorage.shop || "{}");
    }
  };

  Item = {
    haveSameProduct: function(item1, item2) {
      return item1.productId === item2.productId;
    },
    newFromProduct: function(product) {
      return {
        productId: product.id,
        name: product.name,
        count: 1,
        total: product.price,
        price: product.price
      };
    },
    incrementCount: function(item) {
      var count;
      count = item.count + 1;
      return this.update(item, {
        count: count,
        total: item.price * count
      });
    },
    decrementCount: function(item) {
      var count;
      count = item.count - 1;
      return this.update(item, {
        count: count,
        total: item.price * count
      });
    },
    sort: function(items) {
      return _.sortBy(items, "productId");
    },
    update: function(item, props) {
      return Dict.update(item, props);
    }
  };

  Products = {
    findWithId: function(products, id) {
      var i, len, product;
      for (i = 0, len = products.length; i < len; i++) {
        product = products[i];
        if (product.id === id) {
          return product;
        }
      }
    }
  };

  Order = {
    "new": function(items, options) {
      if (items == null) {
        items = [];
      }
      if (options == null) {
        options = {};
      }
      return {
        id: options.id || null,
        items: Item.sort(items),
        total: _.reduce(items, (function(acc, item) {
          return acc + item.total;
        }), 0),
        canBeCaptured: _.some(items),
        isFlashed: options.isFlashed || false,
        capturedAt: options.capturedAt || null
      };
    },
    flashTotal: function(order) {
      return this["new"](order.items, {
        isFlashed: true
      });
    },
    resetFlashes: function(order) {
      return this["new"](order.items, {
        isFlashed: false
      });
    },
    findItem: function(order, productId) {
      return _.findWhere(order.items, {
        productId: productId
      });
    },
    insertItem: function(order, itemToInsert) {
      var items;
      items = _.filter(order.items, function(item) {
        return !Item.haveSameProduct(itemToInsert, item);
      });
      return this["new"](items.concat(itemToInsert));
    },
    removeItem: function(order, itemToInsert) {
      var items;
      items = _.filter(order.items, function(item) {
        return !Item.haveSameProduct(itemToInsert, item);
      });
      return this["new"](items);
    },
    addItem: function(order, product) {
      var item;
      item = this.findItem(order, product.id);
      item = item ? Item.incrementCount(item) : Item.newFromProduct(product);
      return this.insertItem(order, item);
    },
    incrementCount: function(order, product) {
      var item;
      item = this.findItem(order, product.id);
      item = Item.incrementCount(item);
      return this.insertItem(order, item);
    },
    decrementCount: function(order, product) {
      var item;
      item = this.findItem(order, product.id);
      item = Item.decrementCount(item);
      if (item.count === 0) {
        return this.removeItem(order, item);
      } else {
        return this.insertItem(order, item);
      }
    },
    capture: function(order, nextOrderId) {
      return this["new"](order.items, {
        id: nextOrderId,
        capturedAt: Time.now()
      });
    },
    sort: function(orders) {
      return _.sortBy(orders, "id").reverse();
    }
  };

  window.Shop = {
    "new": function(products, order, currentPage) {
      return {
        products: products,
        currentOrder: order || Order["new"](),
        capturedOrders: [],
        currentPage: currentPage || "products",
        nextOrderId: 1
      };
    },
    changePage: function(shop, page) {
      return this.update(shop, {
        currentPage: page
      });
    },
    cancelOrder: function(shop) {
      return this.updateCurrentOrder(shop, Order["new"]());
    },
    addToOrder: function(shop, productId) {
      var order, product;
      product = Products.findWithId(shop.products, productId);
      order = Order.addItem(shop.currentOrder, product);
      return this.updateCurrentOrder(shop, order);
    },
    incrementCountInOrder: function(shop, productId) {
      var order, product;
      product = Products.findWithId(shop.products, productId);
      order = Order.incrementCount(shop.currentOrder, product);
      return this.updateCurrentOrder(shop, order);
    },
    decrementCountInOrder: function(shop, productId) {
      var order, product;
      product = Products.findWithId(shop.products, productId);
      order = Order.decrementCount(shop.currentOrder, product);
      return this.updateCurrentOrder(shop, order);
    },
    captureOrder: function(shop) {
      var order;
      order = Order.capture(shop.currentOrder, shop.nextOrderId);
      return this.update(shop, {
        nextOrderId: shop.nextOrderId + 1,
        capturedOrders: Order.sort(shop.capturedOrders.concat(order)),
        currentOrder: Order["new"]()
      });
    },
    updateCurrentOrder: function(shop, order) {
      return this.update(shop, {
        currentOrder: Order.flashTotal(order)
      });
    },
    update: function(shop, props) {
      var order;
      if (!props.currentOrder) {
        order = Order.resetFlashes(shop.currentOrder);
        props = Dict.update(props, {
          currentOrder: order
        });
      }
      return Dict.update(shop, props);
    }
  };

  shopProducts = [
    {
      id: "e1",
      name: "Elote chico",
      price: 15.00
    }, {
      id: "e2",
      name: "Elote mediano",
      price: 20.00
    }, {
      id: "e3",
      name: "Elote grande",
      price: 25.00
    }, {
      id: "e4",
      name: "Conchitas",
      price: 25.00
    }, {
      id: "e5",
      name: "Tostitos",
      price: 30.00
    }
  ];

  onAction = Actions.onAction;

  onAction("click", "navigateTo", function(shop, $el) {
    var page;
    page = $el.data("page");
    return updateState(Shop.changePage(shop, page));
  });

  onAction("click", "addItem", function(shop, $el) {
    var productId;
    productId = $el.data("id");
    return updateState(Shop.addToOrder(shop, productId));
  });

  onAction("click", "incrementCount", function(shop, $el) {
    var productId;
    productId = $el.data("id");
    return updateState(Shop.incrementCountInOrder(shop, productId));
  });

  onAction("click", "decrementCount", function(shop, $el) {
    var productId;
    productId = $el.data("id");
    return updateState(Shop.decrementCountInOrder(shop, productId));
  });

  onAction("click", "cancelOrder", function(shop) {
    return updateState(Shop.cancelOrder(shop));
  });

  onAction("click", "captureOrder", function(shop) {
    return updateState(Shop.captureOrder(shop));
  });

  updateState = function(shop) {
    App.update(shop);
    return LocalStore.save(shop);
  };

  loadState = function() {
    var shop;
    if (_.isEmpty(shop = LocalStore.load())) {
      return Shop["new"](shopProducts);
    } else {
      return shop;
    }
  };

  $(function() {
    App.init($(".js-app"), loadState());
    return App.render();
  });

}).call(this);
