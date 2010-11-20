(function() {
  var BidDatabase, Redis;
  var __bind = function(func, context) {
    return function(){ return func.apply(context, arguments); };
  };
  Redis = require("redis");
  BidDatabase = function(config, responder) {
    var _this;
    _this = this;
    this.reInitialize = function(){ return BidDatabase.prototype.reInitialize.apply(_this, arguments); };
    this.addBid = function(){ return BidDatabase.prototype.addBid.apply(_this, arguments); };
    this.client = Redis.createClient();
    this.client.on("error", __bind(function(err) {
      return console.log("Redis connection error to " + this.client.host + ":" + this.client.port + " - " + err);
    }, this));
    return this;
  };
  BidDatabase.prototype.watchResponder = function(responder) {
    responder.on("bidReceived", this.addBid);
    return responder.on("resetDatabase", this.reInitialize);
  };
  BidDatabase.prototype.addBid = function(shares, price, bidder) {
    console.log("Adding bid", shares, price, bidder);
    return this.getBidId(__bind(function(bId) {
      this.client.hmset(bId, "shares", shares, "price", price, "bidder", bidder, Redis.print);
      return this.client.zadd("bIds", price, bId, Redis.print);
    }, this));
  };
  BidDatabase.prototype.reInitialize = function() {
    console.log("Resetting database");
    this.client.flushall(Redis.print);
    this.client.incr("global:nextBid", Redis.print);
    return true;
  };
  BidDatabase.prototype.getBidId = function(callback) {
    var x;
    return (x = this.client.incr("global:nextBid", callback));
  };
  exports.BidDatabase = BidDatabase;
}).call(this);
