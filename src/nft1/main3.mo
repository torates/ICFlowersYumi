/*
ERC721 - note the following:
-No notifications (can be added)
-All tokenids are ignored
-You can use the canister address as the token id
-Memo is ignored
-No transferFrom (as transfer includes a from field)
*/

import Cycles "mo:base/ExperimentalCycles";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Int8 "mo:base/Int8";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Blob "mo:base/Blob";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import AID "../motoko/util/AccountIdentifier";
import ExtCore "../motoko/ext/Core";
import ExtCommon "../motoko/ext/Common";
import ExtAllowance "../motoko/ext/Allowance";
import ExtNonFungible "../motoko/ext/NonFungible";
import AssetStorage "assetstorage";
import SVG "SVG";
import Traits "Traits";
import Array "mo:base/Array";
import Option "mo:base/Option";

////import AccountIdentifier "mo:principal/AccountIdentifier";
////import Cap "mo:cap/Cap";
////import CapRouter "mo:cap/Router";
////import EXT "mo:ext/Ext";

//import Admins "../Admins";
//import AssetTypes "../Assets/types";
//import Assets "../Assets";
//import Entrepot "../Entrepot";
//import EntrepotTypes "../Entrepot/types";
//import Ext "../Ext";
//import ExtTypes "../Ext/types";
//import Hex "../NNS/Hex";
//import Http "../Http";
//import HttpTypes "../Http/types";
//import NNS "../NNS";
//import NNSTypes "../NNS/types";
//import Payouts "../Payouts";
//import PayoutsTypes "../Payouts/types";
//import PublicSale "../PublicSale";
//import PublicSaleTypes "../PublicSale/types";
//import TokenTypes "../Tokens/types";
//import Tokens "../Tokens";

shared (install) actor class erc721_token(init_minter: Principal) = this {
  
  // Types
  type AccountIdentifier = ExtCore.AccountIdentifier;
  type SubAccount = ExtCore.SubAccount;
  type User = ExtCore.User;
  type Balance = ExtCore.Balance;
  type TokenIdentifier = ExtCore.TokenIdentifier;
  type TokenIndex  = ExtCore.TokenIndex ;
  type Extension = ExtCore.Extension;
  type CommonError = ExtCore.CommonError;
  type BalanceRequest = ExtCore.BalanceRequest;
  type BalanceResponse = ExtCore.BalanceResponse;
  type TransferRequest = ExtCore.TransferRequest;
  type TransferResponse = ExtCore.TransferResponse;
  type Listing = ExtCore.Listing;
  type AllowanceRequest = ExtAllowance.AllowanceRequest;
  type ApproveRequest = ExtAllowance.ApproveRequest;
  type Metadata = ExtCommon.Metadata;
  type MintRequest  = ExtNonFungible.MintRequest;

  
  private let EXTENSIONS : [Extension] = ["@ext/common", "@ext/allowance", "@ext/nonfungible"];


  
  //State work
  private stable var _registryState : [(TokenIndex, AccountIdentifier)] = [];
  private var _registry : HashMap.HashMap<TokenIndex, AccountIdentifier> = HashMap.fromIter(_registryState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
	
  private stable var _allowancesState : [(TokenIndex, Principal)] = [];
  private var _allowances : HashMap.HashMap<TokenIndex, Principal> = HashMap.fromIter(_allowancesState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
	
	private stable var _tokenMetadataState : [(TokenIndex, Metadata)] = [];
  private var _tokenMetadata : HashMap.HashMap<TokenIndex, Metadata> = HashMap.fromIter(_tokenMetadataState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
  
  private stable var _ownersState : [(AccountIdentifier, [TokenIndex])] = [];
  private var _owners : HashMap.HashMap<AccountIdentifier, [TokenIndex]> = HashMap.fromIter(_ownersState.vals(), 0, AID.equal, AID.hash);
  

  private stable var _supply : Balance  = 0;
  private stable var maxSupply : Nat = 3000;
  private stable var _minter : Principal  = init_minter;
  private stable var _nextTokenId : TokenIndex  = 0;
  private var value = 0;

  //State functions
  system func preupgrade() {
    _registryState := Iter.toArray(_registry.entries());
    _allowancesState := Iter.toArray(_allowances.entries());
    _tokenMetadataState := Iter.toArray(_tokenMetadata.entries());
    _ownersState := Iter.toArray(_owners.entries());
  };
  system func postupgrade() {
    _registryState := [];
    _allowancesState := [];
    _tokenMetadataState := [];
    _ownersState := [];
  };

	public shared(msg) func setMinter(minter : Principal) : async () {
		assert(msg.caller == _minter);
		_minter := minter;
	};


  public func inc() : async Nat {
    value += 1;
    return value;
  };

  public func toBytes(_id: Text) : async Blob {
      return Text.encodeUtf8(_id);
  };
 
  public func tokenIdentifier(c : Text, i : TokenIndex) : async TokenIdentifier {
    return ExtCore.TokenIdentifier.fromText(c, i);
  };

  
	
  public shared(msg) func mintNFT(request : MintRequest) : async TokenIndex {
		assert(msg.caller == _minter);
    let receiver = ExtCore.User.toAID(request.to);
		let token = _nextTokenId;
		let md : Metadata = #nonfungible({
			metadata = request.metadata;
		}); 
		_registry.put(token, receiver);
		_tokenMetadata.put(token, md);
    var tokenstoPut : [TokenIndex] = [];
    switch (_owners.get(receiver)) {
      case (?tokens) {
        tokenstoPut := Array.append(tokens, [token]);
      };
      case (_) {
        tokenstoPut := [token];
      };
    };
    _owners.put(receiver, tokenstoPut);
		_supply := _supply + 1;
		_nextTokenId := _nextTokenId + 1;
    token;
	};

  func getTrait(nums : [Nat]) : [Nat8] { 
    var bgId : Nat8 = 0;
    var potId : Nat8 = 0;
    var stemId : Nat8 = 0;
    var petalId : Nat8 = 0;

    var count : Nat = 0;

    for(i in Iter.fromArray(nums)) {
      if(count == 0) {

        count += 1;
        let syntBg : Nat8 = Traits.bgRarity(i);
        bgId := syntBg;

      } else if(count == 1) {

        count += 1;
        let syntPot : Nat8 = Traits.potRarity(i);
        potId := syntPot;

      } else if(count == 2) {

        count += 1;
        let syntStem : Nat8 = Traits.stemRarity(i);
        stemId := syntStem;

      } else if(count == 3) {

        let syntPetal : Nat8 = Traits.petalRarity(i);
        petalId := syntPetal;
      }
    };

    var arr : [Nat8] = [bgId, potId, stemId, petalId];
    
    return arr;
  };


  public shared(msg) func transfer(request: TransferRequest) : async TransferResponse {
    if (request.amount != 1) {
			return #err(#Other("Must use amount of 1"));
		};
		if (ExtCore.TokenIdentifier.isPrincipal(request.token, Principal.fromActor(this)) == false) {
			return #err(#InvalidToken(request.token));
		};
		let token = ExtCore.TokenIdentifier.getIndex(request.token);
/*     if (Option.isSome(_tokenListing.get(token))) {
			return #err(#Other("This token is currently listed for sale!"));
    }; */
    let owner = ExtCore.User.toAID(request.from);
    let spender = AID.fromPrincipal(msg.caller, request.subaccount);
    let receiver = ExtCore.User.toAID(request.to);
		if (AID.equal(owner, spender) == false) {
      return #err(#Unauthorized(spender));
    };
    switch (_registry.get(token)) {
      case (?token_owner) {
				if(AID.equal(owner, token_owner) == false) {
					return #err(#Unauthorized(owner));
				};
        if (request.notify) {
          switch(ExtCore.User.toPrincipal(request.to)) {
            case (?canisterId) {
              //Do this to avoid atomicity issue
              _removeTokenFromUser(token);
              let notifier : ExtCore.NotifyService = actor(Principal.toText(canisterId));
              switch(await notifier.tokenTransferNotification(request.token, request.from, request.amount, request.memo)) {
                case (?balance) {
                  if (balance == 1) {
                    _transferTokenToUser(token, receiver);
                    return #ok(request.amount);
                  } else {
                    //Refund
                    _transferTokenToUser(token, owner);
                    return #err(#Rejected);
                  };
                };
                case (_) {
                  //Refund
                  _transferTokenToUser(token, owner);
                  return #err(#Rejected);
                };
              };
            };
            case (_) {
              return #err(#CannotNotify(receiver));
            }
          };
        } else {
          _transferTokenToUser(token, receiver);
          return #ok(request.amount);
        };
      };
      case (_) {
        return #err(#InvalidToken(request.token));
      };
    };
  };
  
  public shared(msg) func approve(request: ApproveRequest) : async () {
		if (ExtCore.TokenIdentifier.isPrincipal(request.token, Principal.fromActor(this)) == false) {
			return;
		};
		let token = ExtCore.TokenIdentifier.getIndex(request.token);
    let owner = AID.fromPrincipal(msg.caller, request.subaccount);
		switch (_registry.get(token)) {
      case (?token_owner) {
				if(AID.equal(owner, token_owner) == false) {
					return;
				};
				_allowances.put(token, request.spender);
        return;
      };
      case (_) {
        return;
      };
    };
  };

  public query func extensions() : async [Extension] {
    EXTENSIONS;
  };
  
  public query func balance(request : BalanceRequest) : async BalanceResponse {
		if (ExtCore.TokenIdentifier.isPrincipal(request.token, Principal.fromActor(this)) == false) {
			return #err(#InvalidToken(request.token));
		};
		let token = ExtCore.TokenIdentifier.getIndex(request.token);
    let aid = ExtCore.User.toAID(request.user);
    switch (_registry.get(token)) {
      case (?token_owner) {
				if (AID.equal(aid, token_owner) == true) {
					return #ok(1);
				} else {					
					return #ok(0);
				};
      };
      case (_) {
        return #err(#InvalidToken(request.token));
      };
    };
  };
	
	public query func allowance(request : AllowanceRequest) : async Result.Result<Balance, CommonError> {
		if (ExtCore.TokenIdentifier.isPrincipal(request.token, Principal.fromActor(this)) == false) {
			return #err(#InvalidToken(request.token));
		};
		let token = ExtCore.TokenIdentifier.getIndex(request.token);
		let owner = ExtCore.User.toAID(request.owner);
		switch (_registry.get(token)) {
      case (?token_owner) {
				if (AID.equal(owner, token_owner) == false) {					
					return #err(#Other("Invalid owner"));
				};
				switch (_allowances.get(token)) {
					case (?token_spender) {
						if (Principal.equal(request.spender, token_spender) == true) {
							return #ok(1);
						} else {					
							return #ok(0);
						};
					};
					case (_) {
						return #ok(0);
					};
				};
      };
      case (_) {
        return #err(#InvalidToken(request.token));
      };
    };
  };
  
	public query func bearer(token : TokenIdentifier) : async Result.Result<AccountIdentifier, CommonError> {
		if (ExtCore.TokenIdentifier.isPrincipal(token, Principal.fromActor(this)) == false) {
			return #err(#InvalidToken(token));
		};
		let tokenind = ExtCore.TokenIdentifier.getIndex(token);
    switch (_registry.get(tokenind)) {
      case (?token_owner) {
				return #ok(token_owner);
      };
      case (_) {
        return #err(#InvalidToken(token));
      };
    };
	};
  
	public query func supply(token : TokenIdentifier) : async Result.Result<Balance, CommonError> {
    #ok(_supply);
  };
  
  public query func getRegistry() : async [(TokenIndex, AccountIdentifier)] {
    Iter.toArray(_registry.entries());
  };
  public query func getAllowances() : async [(TokenIndex, Principal)] {
    Iter.toArray(_allowances.entries());
  };
  public query func getTokens() : async [(TokenIndex, Metadata)] {
    Iter.toArray(_tokenMetadata.entries());
  };

  public query func tokens(aid : AccountIdentifier) : async Result.Result<[TokenIndex], CommonError> {
    switch(_owners.get(aid)) {
      case(?tokens) return #ok(tokens);
      case(_) return #err(#Other("No tokens"));
    };
  };


  public query func tokens_ext(aid : AccountIdentifier) : async Result.Result<[(TokenIndex, ?Listing, ?Blob)], CommonError> {
		switch(_owners.get(aid)) {
      case(?tokens) {
        var resp : [(TokenIndex, ?Listing, ?Blob)] = [];
        for (a in tokens.vals()){
          switch(_tokenMetadata.get(a)) {
            case(?md) switch(md) {
              case(#fungible _) resp := Array.append(resp, [(a, null, null)]); //null as its not on shitrepot
              case(#nonfungible nmd) resp := Array.append(resp, [(a, null, nmd.metadata)]);
            };
            case(null) resp := Array.append(resp, [(a, null, null)]);
          };
        };
        return #ok(resp);
      };
      case(_) return #err(#Other("No tokens"));
    };
	};
  
  public query func metadata(token : TokenIdentifier) : async Result.Result<Metadata, CommonError> {
    if (ExtCore.TokenIdentifier.isPrincipal(token, Principal.fromActor(this)) == false) {
			return #err(#InvalidToken(token));
		};
		let tokenind = ExtCore.TokenIdentifier.getIndex(token);
    switch (_tokenMetadata.get(tokenind)) {
      case (?token_metadata) {
				return #ok(token_metadata);
      };
      case (_) {
        return #err(#InvalidToken(token));
      };
    };
  };

    func _removeTokenFromUser(tindex : TokenIndex) : () {
    let owner : ?AccountIdentifier = _getBearer(tindex);
    _registry.delete(tindex);
    switch(owner){
      case (?o) _removeFromUserTokens(tindex, o);
      case (_) {};
    };
  };

  func _transferTokenToUser(tindex : TokenIndex, receiver : AccountIdentifier) : () {
    let owner : ?AccountIdentifier = _getBearer(tindex);
    _registry.put(tindex, receiver);
    switch(owner){
      case (?o) _removeFromUserTokens(tindex, o);
      case (_) {};
    };
    _addToUserTokens(tindex, receiver);
  };
  func _removeFromUserTokens(tindex : TokenIndex, owner : AccountIdentifier) : () {
    switch(_owners.get(owner)) {
      case(?ownersTokens) _owners.put(owner, Array.filter(ownersTokens, func (a : TokenIndex) : Bool { (a != tindex) }));
      case(_) ();
    };
  };
  func _addToUserTokens(tindex : TokenIndex, receiver : AccountIdentifier) : () {
    let ownersTokensNew : [TokenIndex] = switch(_owners.get(receiver)) {
      case(?ownersTokens) Array.append(ownersTokens, [tindex]);
      case(_) [tindex];
    };
    _owners.put(receiver, ownersTokensNew);
  };

  func _getBearer(tindex : TokenIndex) : ?AccountIdentifier {
    _registry.get(tindex);
  };

  let NOT_FOUND : HttpResponse = {status_code = 404; headers = []; body = Blob.fromArray([]); streaming_strategy = null};
  let BAD_REQUEST : HttpResponse = {status_code = 400; headers = []; body = Blob.fromArray([]); streaming_strategy = null};


  type HttpRequest = AssetStorage.HttpRequest;
  type HttpResponse = AssetStorage.HttpResponse;
  
  public query func http_request(request : HttpRequest) : async HttpResponse {
    let path = Iter.toArray(Text.tokens(request.url, #text("/")));
    switch(_getTokenData(_getParam(request.url, "tokenid"))) {
      case (?metadata) {
        //let ids : [Nat8] = getTrait(metadata);
        let padd = Blob.toArray(Text.encodeUtf8("<img src='data:image/svg+xml;base64,"));
        let metaArr = Blob.toArray(metadata);
        let suff = Blob.toArray(Text.encodeUtf8("'/>"));
        let meta = Blob.fromArray(Array.append(Array.append(padd, metaArr), suff));
        return {
          status_code = 200;
          headers = [("content-type", "image/svg+xml")];
          body = meta //when minted, its passed as this encoded: <img src='nft encoded in base64'/>
          //body = Blob.toArray(Text.encodeUtf8(SVG.make(Traits.getBg(ids[0]), Traits.getPot(ids[1]), Traits.getStem(ids[2]), Traits.getPetal(ids[3]))));
        }
      };
      case (_) {
        return {
          status_code = 200;
          headers = [("content-type", "text/plain")];
          body = Text.encodeUtf8("Cycle Balance:                            ~" # debug_show (Cycles.balance()/1000000000000) # "T\n" # "NFTs:                             " # debug_show (_registry.size()) # "\n")
        };
      };
    };
  };
  func _getTokenData(tokenid : ?Text) : ?Blob {
    switch (tokenid) {
      case (?token) {
        if (ExtCore.TokenIdentifier.isPrincipal(token, Principal.fromActor(this)) == false) {
          return null;
        };
        let tokenind = ExtCore.TokenIdentifier.getIndex(token);
        switch (_tokenMetadata.get(tokenind)) {
          case (?token_metadata) {
            switch(token_metadata) {
              case (#fungible data) return null;
              case (#nonfungible data) return data.metadata;
            };
          };
          case (_) {
            return null;
          };
        };
				return null;
      };
      case (_) {
        return null;
      };
    };
  };
  func _getParam(url : Text, param : Text) : ?Text {
    var _s : Text = url;
    Iter.iterate<Text>(Text.split(_s, #text("/")), func(x, _i) {
      _s := x;
    });
    Iter.iterate<Text>(Text.split(_s, #text("?")), func(x, _i) {
      if (_i == 1) _s := x;
    });
    var t : ?Text = null;
    var found : Bool = false;
    Iter.iterate<Text>(Text.split(_s, #text("&")), func(x, _i) {
      Iter.iterate<Text>(Text.split(x, #text("=")), func(y, _ii) {
        if (_ii == 0) {
          if (Text.equal(y, param)) found := true;
        } else if (found == true) t := ?y;
      });
    });
    return t;
  };


  

 /*  let ONE_ICP_IN_E8S = 1_000_000;

  stable var invoicesStable : [(Principal, Invoice.Invoice)] = [];
  var invoices: HashMap.HashMap<Principal, Invoice.Invoice> = HashMap.HashMap(16, Principal.equal, Principal.hash);

  stable var licensesStable : [(Principal, Bool)] = [];
  var licenses: HashMap.HashMap<Principal, Bool> = HashMap.HashMap(16, Principal.equal, Principal.hash);
 */
// #region create_invoice
/*
  public shared ({caller}) func create_invoice() : async Invoice.CreateInvoiceResult {
     let permissionz : ?Permissions = {
      canGet = [caller];
      canVerify = [caller];
    }; */
    /*
    let invoiceCreateArgs : Invoice.CreateInvoiceArgs = {
      amount = ONE_ICP_IN_E8S / 10;
      token = {
        symbol = "ICP";
      };
      permissions = null;
      details = ?{
        description = "Example license certifying status";
        // JSON string as a blob
        meta = Text.encodeUtf8(
          "{\n" #
          "  \"seller\": \"Invoice Canister Example Dapp\",\n" #
          "  \"itemized_bill\": [\"Standard License\"],\n" #
          "}"
        );
      };
    };
    let invoiceResult = await Invoice.create_invoice(invoiceCreateArgs);
    switch(invoiceResult){
      case(#err _) {};
      case(#ok result) {
        invoices.put(caller, result.invoice);
      };
    };
    return invoiceResult;
  };

  public shared query ({caller}) func check_license_status() : async Bool {
    let licenseResult = licenses.get(caller);
    switch(licenseResult) {
      case(null){
        return false;
      };
      case (? license){
        return license;
      };
    };
  };

  public shared query ({caller}) func get_invoice() : async ?Invoice.Invoice {
    invoices.get(caller);
  };

  public shared ({caller}) func verify_invoice() : async Invoice.VerifyInvoiceResult {
    let invoiceResult = invoices.get(caller);
    switch(invoiceResult){
      case(null){
        return #err({
          kind = #Other;
          message = ?"Invoice not found for this user";
        });
      };
      case (? invoice){
        let verifyResult = await Invoice.verify_invoice({id = invoice.id});
        if (Result.isOk(verifyResult)){
          // update invoices with the verified invoice
          invoices.put(caller, invoice);

          // update licenses with the verified invoice
          licenses.put(caller, true);
        };
        return verifyResult;
      };
    };
  }; */

// #region Utils
  public query func remaining_cycles() : async Nat {
    return Cycles.balance()
  };
// #endregion




  
  //Internal cycle management - good general case
  public func acceptCycles() : async () {
    let available = Cycles.available();
    let accepted = Cycles.accept(available);
    assert (accepted == available);
  };
  public query func availableCycles() : async Nat {
    return Cycles.balance();
  };

}


// possibble solution, premint 3k icflower nfts, to an address