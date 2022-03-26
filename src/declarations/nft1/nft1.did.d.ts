import type { Principal } from '@dfinity/principal';
<<<<<<< HEAD
export type AccountIdentifier = { 'principal' : Principal } |
  { 'blob' : Array<number> } |
  { 'text' : string };
export type AccountIdentifier__1 = string;
export type AccountIdentifier__2 = string;
=======
export type AccountIdentifier = string;
export type AccountIdentifier__1 = string;
>>>>>>> 0838e5d3e009742de0a1933affcdd17062508450
export interface AllowanceRequest {
  'token' : TokenIdentifier,
  'owner' : User,
  'spender' : Principal,
}
export interface ApproveRequest {
  'token' : TokenIdentifier,
  'subaccount' : [] | [SubAccount],
  'allowance' : Balance,
  'spender' : Principal,
}
export type Balance = bigint;
export interface BalanceRequest { 'token' : TokenIdentifier, 'user' : User }
export type BalanceResponse = { 'ok' : Balance } |
  { 'err' : CommonError__1 };
export type Balance__1 = bigint;
export type CommonError = { 'InvalidToken' : TokenIdentifier } |
  { 'Other' : string };
export type CommonError__1 = { 'InvalidToken' : TokenIdentifier } |
  { 'Other' : string };
<<<<<<< HEAD
export interface CreateInvoiceErr {
  'kind' : { 'InvalidDetails' : null } |
    { 'InvalidAmount' : null } |
    { 'InvalidDestination' : null } |
    { 'InvalidToken' : null } |
    { 'Other' : null },
  'message' : [] | [string],
}
export type CreateInvoiceResult = { 'ok' : CreateInvoiceSuccess } |
  { 'err' : CreateInvoiceErr };
export interface CreateInvoiceSuccess { 'invoice' : Invoice }
export interface Details { 'meta' : Array<number>, 'description' : string }
=======
>>>>>>> 0838e5d3e009742de0a1933affcdd17062508450
export type Extension = string;
export type HeaderField = [string, string];
export interface HttpRequest {
  'url' : string,
  'method' : string,
  'body' : Array<number>,
  'headers' : Array<HeaderField>,
}
export interface HttpResponse {
  'body' : Array<number>,
  'headers' : Array<HeaderField>,
  'streaming_strategy' : [] | [StreamingStrategy],
  'status_code' : number,
}
<<<<<<< HEAD
export interface Invoice {
  'id' : bigint,
  'permissions' : [] | [Permissions],
  'creator' : Principal,
  'destination' : AccountIdentifier,
  'token' : TokenVerbose,
  'paid' : boolean,
  'verifiedAtTime' : [] | [bigint],
  'amountPaid' : bigint,
  'expiration' : bigint,
  'details' : [] | [Details],
  'amount' : bigint,
}
=======
>>>>>>> 0838e5d3e009742de0a1933affcdd17062508450
export type Memo = Array<number>;
export type Metadata = {
    'fungible' : {
      'decimals' : number,
      'metadata' : [] | [Array<number>],
      'name' : string,
      'symbol' : string,
    }
  } |
  { 'nonfungible' : { 'metadata' : [] | [Array<number>] } };
export interface MintRequest { 'to' : User, 'metadata' : [] | [Array<number>] }
<<<<<<< HEAD
export interface Permissions {
  'canGet' : Array<Principal>,
  'canVerify' : Array<Principal>,
}
=======
>>>>>>> 0838e5d3e009742de0a1933affcdd17062508450
export type Result = { 'ok' : Balance__1 } |
  { 'err' : CommonError };
export type Result_1 = { 'ok' : Metadata } |
  { 'err' : CommonError };
<<<<<<< HEAD
export type Result_2 = { 'ok' : AccountIdentifier__2 } |
=======
export type Result_2 = { 'ok' : AccountIdentifier__1 } |
>>>>>>> 0838e5d3e009742de0a1933affcdd17062508450
  { 'err' : CommonError };
export interface StreamingCallbackHttpResponse {
  'token' : [] | [StreamingCallbackToken],
  'body' : Array<number>,
}
export interface StreamingCallbackToken {
  'key' : string,
  'sha256' : [] | [Array<number>],
  'index' : bigint,
  'content_encoding' : string,
}
export type StreamingStrategy = {
    'Callback' : {
      'token' : StreamingCallbackToken,
      'callback' : [Principal, string],
    }
  };
export type SubAccount = Array<number>;
export type TokenIdentifier = string;
export type TokenIdentifier__1 = string;
export type TokenIndex = number;
<<<<<<< HEAD
export interface TokenVerbose {
  'decimals' : bigint,
  'meta' : [] | [{ 'Issuer' : string }],
  'symbol' : string,
}
=======
>>>>>>> 0838e5d3e009742de0a1933affcdd17062508450
export interface TransferRequest {
  'to' : User,
  'token' : TokenIdentifier,
  'notify' : boolean,
  'from' : User,
  'memo' : Memo,
  'subaccount' : [] | [SubAccount],
  'amount' : Balance,
}
export type TransferResponse = { 'ok' : Balance } |
  {
<<<<<<< HEAD
    'err' : { 'CannotNotify' : AccountIdentifier__1 } |
      { 'InsufficientBalance' : null } |
      { 'InvalidToken' : TokenIdentifier } |
      { 'Rejected' : null } |
      { 'Unauthorized' : AccountIdentifier__1 } |
      { 'Other' : string }
  };
export type User = { 'principal' : Principal } |
  { 'address' : AccountIdentifier__1 };
export interface VerifyInvoiceErr {
  'kind' : { 'InvalidAccount' : null } |
    { 'TransferError' : null } |
    { 'NotFound' : null } |
    { 'NotAuthorized' : null } |
    { 'InvalidToken' : null } |
    { 'InvalidInvoiceId' : null } |
    { 'Other' : null } |
    { 'NotYetPaid' : null } |
    { 'Expired' : null },
  'message' : [] | [string],
}
export type VerifyInvoiceResult = { 'ok' : VerifyInvoiceSuccess } |
  { 'err' : VerifyInvoiceErr };
export type VerifyInvoiceSuccess = { 'Paid' : { 'invoice' : Invoice } } |
  { 'AlreadyVerified' : { 'invoice' : Invoice } };
=======
    'err' : { 'CannotNotify' : AccountIdentifier } |
      { 'InsufficientBalance' : null } |
      { 'InvalidToken' : TokenIdentifier } |
      { 'Rejected' : null } |
      { 'Unauthorized' : AccountIdentifier } |
      { 'Other' : string }
  };
export type User = { 'principal' : Principal } |
  { 'address' : AccountIdentifier };
>>>>>>> 0838e5d3e009742de0a1933affcdd17062508450
export interface erc721_token {
  'acceptCycles' : () => Promise<undefined>,
  'allowance' : (arg_0: AllowanceRequest) => Promise<Result>,
  'approve' : (arg_0: ApproveRequest) => Promise<undefined>,
  'availableCycles' : () => Promise<bigint>,
  'balance' : (arg_0: BalanceRequest) => Promise<BalanceResponse>,
  'bearer' : (arg_0: TokenIdentifier__1) => Promise<Result_2>,
<<<<<<< HEAD
  'check_license_status' : () => Promise<boolean>,
  'create_invoice' : () => Promise<CreateInvoiceResult>,
  'extensions' : () => Promise<Array<Extension>>,
  'getAllowances' : () => Promise<Array<[TokenIndex, Principal]>>,
  'getRegistry' : () => Promise<Array<[TokenIndex, AccountIdentifier__2]>>,
  'getTokens' : () => Promise<Array<[TokenIndex, Metadata]>>,
  'getTrait' : (arg_0: Array<bigint>) => Promise<Array<number>>,
  'get_invoice' : () => Promise<[] | [Invoice]>,
=======
  'extensions' : () => Promise<Array<Extension>>,
  'getAllowances' : () => Promise<Array<[TokenIndex, Principal]>>,
  'getRegistry' : () => Promise<Array<[TokenIndex, AccountIdentifier__1]>>,
  'getTokens' : () => Promise<Array<[TokenIndex, Metadata]>>,
>>>>>>> 0838e5d3e009742de0a1933affcdd17062508450
  'http_request' : (arg_0: HttpRequest) => Promise<HttpResponse>,
  'inc' : () => Promise<bigint>,
  'metadata' : (arg_0: TokenIdentifier__1) => Promise<Result_1>,
  'mintNFT' : (arg_0: MintRequest) => Promise<TokenIndex>,
<<<<<<< HEAD
  'remaining_cycles' : () => Promise<bigint>,
=======
>>>>>>> 0838e5d3e009742de0a1933affcdd17062508450
  'setMinter' : (arg_0: Principal) => Promise<undefined>,
  'supply' : (arg_0: TokenIdentifier__1) => Promise<Result>,
  'toBytes' : (arg_0: string) => Promise<Array<number>>,
  'tokenIdentifier' : (arg_0: string, arg_1: TokenIndex) => Promise<
      TokenIdentifier__1
    >,
  'transfer' : (arg_0: TransferRequest) => Promise<TransferResponse>,
<<<<<<< HEAD
  'verify_invoice' : () => Promise<VerifyInvoiceResult>,
=======
>>>>>>> 0838e5d3e009742de0a1933affcdd17062508450
}
export interface _SERVICE extends erc721_token {}
