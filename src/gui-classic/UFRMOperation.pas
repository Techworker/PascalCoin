unit UFRMOperation;

{ Copyright (c) 2016 by Albert Molina

  Distributed under the MIT software license, see the accompanying file LICENSE
  or visit http://www.opensource.org/licenses/mit-license.php.

  This unit is a part of the PascalCoin Project, an infinitely scalable
  cryptocurrency. Find us here:
  Web: https://www.pascalcoin.org
  Source: https://github.com/PascalCoin/PascalCoin

  If you like it, consider a donation using Bitcoin:
  16K3HCZRhFUtM8GdWRcfKeaa6KsuyxZaYk

  THIS LICENSE HEADER MUST NOT BE REMOVED.
}

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFnDEF FPC}
  Windows,
  System.Actions,
{$ELSE}
  LCLIntf, LCLType, LMessages,
{$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, UNode, UWallet, UCrypto, Buttons, UBlockChain,
  UAccounts, UFRMAccountSelect, ActnList, ComCtrls, Types, UFRMMemoText,
  UPCEncryption, UBaseTypes, UPCOrderedLists;

Const
  CM_PC_WalletKeysChanged = WM_USER + 1;

type

  { TFRMOperation }

  TFRMOperation = class(TForm)
    ebChangeName: TEdit;
    ebChangeType: TEdit;
    ebSignerAccount: TEdit;
    lblSignerAccount: TLabel;
    lblAccountCaption: TLabel;
    bbExecute: TBitBtn;
    bbCancel: TBitBtn;
    lblAccountBalance: TLabel;
    lblChangeType: TLabel;
    lblChangeName: TLabel;
    lblBalanceCaption: TLabel;
    ebSenderAccount: TEdit;
    lblChangeInfoErrors: TLabel;
    PageControlLocked: TPageControl;
    sbSearchBuyAccount: TSpeedButton;
    sbSearchDestinationAccount: TSpeedButton;
    sbSearchSignerAccount: TSpeedButton;
    tsChangeInfo: TTabSheet;
    tsOperation: TTabSheet;
    gbPayload: TGroupBox;
    lblEncryptPassword: TLabel;
    Label4: TLabel;
    lblEncryptionErrors: TLabel;
    lblPayloadLength: TLabel;
    rbEncryptedWithEC: TRadioButton;
    rbEncrptedWithPassword: TRadioButton;
    rbNotEncrypted: TRadioButton;
    ebEncryptPassword: TEdit;
    memoPayload: TMemo;
    rbEncryptedWithOldEC: TRadioButton;
    ActionList: TActionList;
    actExecute: TAction;
    tsGlobalError: TTabSheet;
    lblGlobalErrors: TLabel;
    bbPassword: TBitBtn;
    memoAccounts: TMemo;
    lblAccountsCount: TLabel;
    lblFee: TLabel;
    ebFee: TEdit;
    PageControlOpType: TPageControl;
    tsTransaction: TTabSheet;
    lblDestAccount: TLabel;
    lblAmount: TLabel;
    lblTransactionErrors: TLabel;
    ebDestAccount: TEdit;
    ebAmount: TEdit;
    tsChangePrivateKey: TTabSheet;
    tsListAccount: TTabSheet;
    tsDelistAccount: TTabSheet;
    tsBuyAccount: TTabSheet;
    lblAccountToBuy: TLabel;
    ebAccountToBuy: TEdit;
    lblBuyAmount: TLabel;
    ebBuyAmount: TEdit;
    lblBuyAccountErrors: TLabel;
    lblBuyNewKey: TLabel;
    cbBuyNewKey: TComboBox;
    bbBuyNewKey: TBitBtn;
    Label2: TLabel;
    lblDelistErrors: TLabel;
    lblListAccountErrors: TLabel;
    rbListAccountForPublicSale: TRadioButton;
    rbListAccountForPrivateSale: TRadioButton;
    rbListAccountForAccountSwap: TRadioButton;
    rbListAccountForCoinSwap: TRadioButton;
    lblPrice: TLabel;
    ebPrice: TEdit;
    lblSeller: TLabel;
    ebSellerAccount: TEdit;
    sbSearchListerSellerAccount: TSpeedButton;
    ebNewKey: TEdit;
    lblNewKey: TLabel;
    lblTimeLock: TLabel;
    ebTimeLock: TEdit;
    rbChangeKeyWithAnother: TRadioButton;
    lblNewPrivateKey: TLabel;
    cbNewPrivateKey: TComboBox;
    lblChangeKeyErrors: TLabel;
    bbChangePrivateKeyKeys: TBitBtn;
    lblNewOwnerErrors: TLabel;
    rbChangeKeyTransferAccountToNewOwner: TRadioButton;
    lblNewOwnerPublicKey: TLabel;
    ebNewPublicKey: TEdit;
    lblHashLock: TLabel;
    ebHashLock: TEdit;
    btnHashLock: TSpeedButton;
    sbTimeLock: TSpeedButton;
    cbPayloadAsHex: TCheckBox;
    lblChangeAccountData: TLabel;
    ebChangeAccountData: TEdit;
    procedure ebNewPublicKeyExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure memoPayloadClick(Sender: TObject);
    procedure ebEncryptPasswordChange(Sender: TObject);
    procedure bbChangePrivateKeyKeysClick(Sender: TObject);
    procedure actExecuteExecute(Sender: TObject);
    procedure ebSenderAccountExit(Sender: TObject);
    procedure ebSenderAccountKeyPress(Sender: TObject; var Key: Char);
    procedure bbPasswordClick(Sender: TObject);
    procedure PageControlOpTypeChange(Sender: TObject);
    procedure sbSearchBuyAccountClick(Sender: TObject);
    procedure sbSearchDestinationAccountClick(Sender: TObject);
    procedure sbSearchListerSellerAccountClick(Sender: TObject);
    procedure sbSearchSignerAccountClick(Sender: TObject);
    procedure sbHashLockClick(Sender: TObject);
    procedure updateInfoClick(Sender: TObject);
    procedure bbBuyNewKeyClick(Sender: TObject);
    procedure ebAccountNumberExit(Sender: TObject);
    procedure ebCurrencyExit(Sender: TObject);
  private
    FNode : TNode;
    FWalletKeys: TWalletKeys;
    FDefaultFee: Int64;
    FEncodedPayload : TRawBytes;
    FDisabled : Boolean;
    FSenderAccounts: TOrderedCardinalList; // TODO: TOrderedCardinalList should be replaced with a "TCardinalList" since signer account should be processed last
    procedure SetWalletKeys(const Value: TWalletKeys);
    Procedure UpdateWalletKeys;
    { Private declarations }
    Procedure UpdateAccountsInfo;
    Function UpdateFee(var Fee : Int64; errors : String) : Boolean;
    Function UpdateOperationOptions(var errors : String) : Boolean;
    Function UpdatePayload(Const SenderAccount : TAccount; var errors : String) : Boolean;
    Function UpdateOpTransaction(Const SenderAccount : TAccount; var DestAccount : TAccount; var amount : Int64; var errors : String) : Boolean;
    Function UpdateOpChangeKey(Const TargetAccount : TAccount; var SignerAccount : TAccount; var NewPublicKey : TAccountKey; var errors : String) : Boolean;
    Function UpdateOpListAccount(Const TargetAccount : TAccount; var SalePrice : Int64; var SellerAccount,SignerAccount : TAccount; var NewOwnerPublicKey : TAccountKey; var LockedUntilBlock : Cardinal; var HashLock : T32Bytes; var errors : String) : Boolean;
    Function UpdateOpDelist(Const TargetAccount : TAccount; var SignerAccount : TAccount; var errors : String) : Boolean;
    Function UpdateOpBuyAccount(Const SenderAccount : TAccount; var AccountToBuy : TAccount; var amount : Int64; var NewPublicKey : TAccountKey; var ARecipientSigned : Boolean; var errors : String) : Boolean;
    Function UpdateOpChangeInfo(Const TargetAccount : TAccount; var SignerAccount : TAccount; var changeName : Boolean; var newName : TRawBytes; var changeType : Boolean; var newType : Word; var AChangeData : Boolean; var ANewData : TRawBytes; var errors : String) : Boolean;
    procedure SetDefaultFee(const Value: Int64);
    Procedure OnSenderAccountsChanged(Sender : TObject);
    procedure OnWalletKeysChanged(Sender : TObject);
    procedure CM_WalletChanged(var Msg: TMessage); message CM_PC_WalletKeysChanged;
    Function GetDefaultSenderAccount : TAccount;
    procedure ebAccountKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  protected
    procedure searchAccount(editBox : TCustomEdit);
  public
    { Public declarations }
    Property SenderAccounts : TOrderedCardinalList read FSenderAccounts;
    Property WalletKeys : TWalletKeys read FWalletKeys write SetWalletKeys;
    Property DefaultFee : Int64 read FDefaultFee write SetDefaultFee;
  end;

implementation

uses
  UConst, UOpTransaction, UFRMNewPrivateKeyType, UFRMWalletKeys, UFRMHashLock,
  UCommon, UPCDataTypes, ULog, UGUIUtils;

{$IFnDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

{ TFRMOperation }

procedure TFRMOperation.actExecuteExecute(Sender: TObject);
Var errors : String;
  P : PAccount;
  i,iAcc : Integer;
  LKey : TWalletKey;
  ops : TOperationsHashTree;
  op : TPCOperation;
  account,signerAccount,destAccount,accountToBuy : TAccount;
  operation_to_string, operationstxt, auxs : String;
  _amount,_fee, _totalamount, _totalfee, _totalSignerFee, _salePrice : Int64;
  _lockedUntil, _signer_n_ops : Cardinal;
  dooperation : Boolean;
  _newOwnerPublicKey : TECDSA_Public;
  LHashLock : T32Bytes;
  _newName, LNewAccountData : TRawBytes;
  _newType : Word;
  _changeName, _changeType, LChangeAccountData, _V2, _executeSigner, LRecipientSigned : Boolean;
  _senderAccounts : TCardinalsArray;
label loop_start;
begin
  if Not Assigned(WalletKeys) then raise Exception.Create('No wallet keys');
  If Not UpdateOperationOptions(errors) then raise Exception.Create(errors);
  ops := TOperationsHashTree.Create;
  Try
    _V2 := FNode.Bank.SafeBox.CurrentProtocol >= CT_PROTOCOL_2;
    _totalamount := 0;
    _totalfee := 0;
    _totalSignerFee := 0;
    _signer_n_ops := 0;
    operationstxt := '';
    operation_to_string := '';

    // Compile FSenderAccounts into a reorderable array
    _senderAccounts := FSenderAccounts.ToArray;

    // Loop through each sender account
    for iAcc := 0 to Length(_senderAccounts) - 1 do begin
loop_start:
      op := Nil;
      account := FNode.GetMempoolAccount(_senderAccounts[iAcc]);
      If Not UpdatePayload(account, errors) then
        raise Exception.Create('Error encoding payload of sender account '+TAccountComp.AccountNumberToAccountTxtNumber(account.account)+': '+errors);
      if NOT WalletKeys.TryGetKey(account.accountInfo.accountKey, LKey) then
        Raise Exception.Create('Sender account private key not found in Wallet');
      dooperation := true;
      // Default fee
      if account.balance > uint64(DefaultFee) then _fee := DefaultFee else _fee := account.balance;
      // Determine which operation type it is
      if PageControlOpType.ActivePage = tsTransaction then begin
        {%region Operation: Transaction}
        if Not UpdateOpTransaction(account,destAccount,_amount,errors) then raise Exception.Create(errors);
        if Length(_senderAccounts) > 1 then begin
          if account.balance>0 then begin
            if account.balance>DefaultFee then begin
              _amount := account.balance - DefaultFee;
              _fee := DefaultFee;
            end else begin
              _amount := account.balance;
              _fee := 0;
            end;
          end else dooperation := false;
        end else begin
        end;
        if dooperation then begin
          op := TOpTransaction.CreateTransaction(FNode.Bank.Safebox.CurrentProtocol,account.account,account.n_operation+1,destAccount.account,LKey.PrivateKey,_amount,_fee,FEncodedPayload);
          inc(_totalamount,_amount);
          inc(_totalfee,_fee);
        end;
        operationstxt := 'Transaction to '+TAccountComp.AccountNumberToAccountTxtNumber(destAccount.account);
        {%endregion}
      end else if (PageControlOpType.ActivePage = tsChangePrivateKey) then begin
        {%region Operation: Change Private Key}
        if Not UpdateOpChangeKey(account,signerAccount,_newOwnerPublicKey,errors) then raise Exception.Create(errors);
        if _V2 then begin
          // must ensure is Signer account last if included in sender accounts (not necessarily ordered enumeration)
          if (iAcc < Length(_senderAccounts) - 1) AND (account.account = signerAccount.account) then begin
            TArrayTool<Cardinal>.Swap(_senderAccounts, iAcc, Length(_senderAccounts) - 1); // ensure signer account processed last
            goto loop_start; // TODO: remove ugly hack with refactoring!
          end;

          // Maintain correct signer fee distribution
          if uint64(_totalSignerFee) >= signerAccount.balance then _fee := 0
          else if signerAccount.balance - uint64(_totalSignerFee) > uint64(DefaultFee) then _fee := DefaultFee
          else _fee := signerAccount.balance - uint64(_totalSignerFee);
          op := TOpChangeKeySigned.Create(FNode.Bank.SafeBox.CurrentProtocol,signerAccount.account,signerAccount.n_operation+_signer_n_ops+1,account.account,LKey.PrivateKey,_newOwnerPublicKey,_fee,FEncodedPayload);
          inc(_signer_n_ops);
          inc(_totalSignerFee, _fee);
        end else begin
          op := TOpChangeKey.Create(FNode.Bank.SafeBox.CurrentProtocol,account.account,account.n_operation+1,account.account,LKey.PrivateKey,_newOwnerPublicKey,_fee,FEncodedPayload);
        end;
        inc(_totalfee,_fee);
        operationstxt := 'Change private key to '+TAccountComp.GetECInfoTxt(_newOwnerPublicKey.EC_OpenSSL_NID);
        {%endregion}
      end else if (PageControlOpType.ActivePage = tsListAccount) then begin
        {%region Operation: List For Sale}
        If Not UpdateOpListAccount(account,_salePrice,destAccount,signerAccount,_newOwnerPublicKey, _lockedUntil, LHashLock, errors) then raise Exception.Create(errors);
        // Special fee account:
        if signerAccount.balance>DefaultFee then _fee := DefaultFee
        else _fee := signerAccount.balance;
        if (rbListAccountForPublicSale.Checked) then begin
          op := TOpListAccountForSaleOrSwap.CreateListAccountForSaleOrSwap(FNode.Bank.SafeBox.CurrentProtocol, as_ForSale, signerAccount.account,signerAccount.n_operation+1+iAcc, account.account,_salePrice,_fee,
            destAccount.account,CT_TECDSA_Public_Nul,0,LKey.PrivateKey, CT_HashLock_NUL, FEncodedPayload);
        end else if (rbListAccountForPrivateSale.Checked) then begin
          op := TOpListAccountForSaleOrSwap.CreateListAccountForSaleOrSwap(FNode.Bank.SafeBox.CurrentProtocol, as_ForSale, signerAccount.account,signerAccount.n_operation+1+iAcc, account.account,_salePrice,_fee,
            destAccount.account,_newOwnerPublicKey,_lockedUntil,LKey.PrivateKey, CT_HashLock_NUL, FEncodedPayload);
        end  else if (rbListAccountForAccountSwap.Checked) then begin
          op := TOpListAccountForSaleOrSwap.CreateListAccountForSaleOrSwap(FNode.Bank.SafeBox.CurrentProtocol, as_ForAtomicAccountSwap, signerAccount.account,signerAccount.n_operation+1+iAcc, account.account,_salePrice,_fee,
            destAccount.account,_newOwnerPublicKey,_lockedUntil,LKey.PrivateKey, LHashLock, FEncodedPayload);
        end  else if (rbListAccountForCoinSwap.Checked) then begin
          op := TOpListAccountForSaleOrSwap.CreateListAccountForSaleOrSwap(FNode.Bank.SafeBox.CurrentProtocol, as_ForAtomicCoinSwap, signerAccount.account,signerAccount.n_operation+1+iAcc, account.account,_salePrice,_fee,
            destAccount.account,CT_TECDSA_Public_Nul,_lockedUntil,LKey.PrivateKey, LHashLock, FEncodedPayload);
        end else raise Exception.Create('Select Sale type');
        {%endregion}
      end else if (PageControlOpType.ActivePage = tsDelistAccount) then begin
        {%region Operation: Delist For Sale}
        if Not UpdateOpDelist(account,signerAccount,errors) then raise Exception.Create(errors);
        // Special fee account:
        if signerAccount.balance>DefaultFee then _fee := DefaultFee
        else _fee := signerAccount.balance;
        op := TOpDelistAccountForSale.CreateDelistAccountForSale(FNode.Bank.SafeBox.CurrentProtocol,signerAccount.account,signerAccount.n_operation+1+iAcc,account.account,_fee,LKey.PrivateKey,FEncodedPayload);
        {%endregion}
      end else if (PageControlOpType.ActivePage = tsBuyAccount) then begin
        {%region Operation: Buy Account}
        if Not UpdateOpBuyAccount(account,accountToBuy,_amount,_newOwnerPublicKey, LRecipientSigned, errors) then raise Exception.Create(errors);
        if LRecipientSigned AND (NOT WalletKeys.TryGetKey(account.accountInfo.new_publicKey, LKey)) then
          raise Exception.Create('Recipient-signed key not found in Wallet');
        op := TOpBuyAccount.CreateBuy(FNode.Bank.Safebox.CurrentProtocol,account.account,account.n_operation+1,accountToBuy.account,accountToBuy.accountInfo.account_to_pay,
          accountToBuy.accountInfo.price,_amount,_fee,_newOwnerPublicKey,LKey.PrivateKey,FEncodedPayload);
        {%endregion}
      end else if (PageControlOpType.ActivePage = tsChangeInfo) then begin
        {%region Operation: Change Info}
        if not UpdateOpChangeInfo(account,signerAccount,_changeName,_newName,_changeType,_newType,LChangeAccountData,LNewAccountData,errors) then begin
          If Length(_senderAccounts)=1 then raise Exception.Create(errors);
        end else begin
          if signerAccount.balance>DefaultFee then _fee := DefaultFee
          else _fee := signerAccount.balance;
          op := TOpChangeAccountInfo.CreateChangeAccountInfo(FNode.Bank.SafeBox.CurrentProtocol,signerAccount.account,signerAccount.n_operation+1,account.account,LKey.PrivateKey,false,CT_TECDSA_Public_Nul,
             _changeName,_newName,_changeType,_newType,
             LChangeAccountData,LNewAccountData,
             _fee,FEncodedPayload);
        end;
        {%endregion}
      end else begin
        raise Exception.Create('No operation selected');
      end;
      if Assigned(op) And (dooperation) then begin
        ops.AddOperationToHashTree(op);
        if operation_to_string<>'' then operation_to_string := operation_to_string + #10;
        operation_to_string := operation_to_string + op.ToString;
      end;
      FreeAndNil(op);
    end;

    if (ops.OperationsCount=0) then raise Exception.Create('No valid operation to execute');

    if (Length(_senderAccounts)>1) then begin
      if PageControlOpType.ActivePage = tsTransaction then auxs := 'Total amount that dest will receive: '+TAccountComp.FormatMoney(_totalamount)+#10
      else auxs:='';
      if Application.MessageBox(PChar('Execute '+Inttostr(Length(_senderAccounts))+' operations?'+#10+
        'Operation: '+operationstxt+#10+
        auxs+
        'Total fee: '+TAccountComp.FormatMoney(_totalfee)+#10+#10+'Note: This operation will be transmitted to the network!'),
        PChar(Application.Title),MB_YESNO+MB_ICONINFORMATION+MB_DEFBUTTON2)<>IdYes then exit;
    end else begin
      if Application.MessageBox(PChar('Execute this operation:'+#10+#10+operation_to_string+#10+#10+'Note: This operation will be transmitted to the network!'),
        PChar(Application.Title),MB_YESNO+MB_ICONINFORMATION+MB_DEFBUTTON2)<>IdYes then exit;
    end;
    i := FNode.AddOperations(nil,ops,Nil,errors);
    if (i=ops.OperationsCount) then begin
      operationstxt := 'Successfully executed '+inttostr(i)+' operations!'+#10+#10+operation_to_string;
      If i>1 then begin
        With TFRMMemoText.Create(Self) do
        Try
          InitData(Application.Title,operationstxt);
          ShowModal;
        finally
          Free;
        end;
      end else begin
        Application.MessageBox(PChar('Successfully executed '+inttostr(i)+' operations!'+#10+#10+operation_to_string),PChar(Application.Title),MB_OK+MB_ICONINFORMATION);
      end;
      ModalResult := MrOk;
    end else if (i>0) then begin
      operationstxt := 'One or more of your operations has not been executed:'+#10+
        'Errors:'+#10+
        errors+#10+#10+
        'Total successfully executed operations: '+inttostr(i);
      With TFRMMemoText.Create(Self) do
      Try
        InitData(Application.Title,operationstxt);
        ShowModal;
      finally
        Free;
      end;
      ModalResult := MrOk;
    end else begin
      raise Exception.Create(errors);
    end;
  Finally
    ops.Free;
  End;
end;

procedure TFRMOperation.bbBuyNewKeyClick(Sender: TObject);
Var FRM : TFRMWalletKeys;
begin
  FRM := TFRMWalletKeys.Create(Self);
  Try
    FRM.WalletKeys := WalletKeys;
    FRM.ShowModal;
    cbBuyNewKey.SetFocus;
    UpdateWalletKeys;
  Finally
    FRM.Free;
  End;
end;

procedure TFRMOperation.bbChangePrivateKeyKeysClick(Sender: TObject);
Var FRM : TFRMWalletKeys;
begin
  FRM := TFRMWalletKeys.Create(Self);
  Try
    FRM.WalletKeys := WalletKeys;
    FRM.ShowModal;
    rbChangeKeyWithAnother.Checked := true;
    cbNewPrivateKey.SetFocus;
    UpdateWalletKeys;
  Finally
    FRM.Free;
  End;
end;

procedure TFRMOperation.bbPasswordClick(Sender: TObject);
Var s : String;
  errors : String;
begin
  if FWalletKeys.IsValidPassword then begin
  end else begin
    s := '';
    Repeat
      if Not InputQueryPassword('Wallet password','Enter wallet password',s) then exit;
      FWalletKeys.WalletPassword := s;
    Until FWalletKeys.IsValidPassword;
    SetWalletKeys(WalletKeys);
    UpdateOperationOptions(errors);
  end;
end;


procedure TFRMOperation.CM_WalletChanged(var Msg: TMessage);
begin
   UpdateWalletKeys;
end;

procedure TFRMOperation.ebAccountNumberExit(Sender: TObject);
Var an : Cardinal;
  eb : TEdit;
begin
  if (Not assigned(Sender)) then exit;
  if (Not (Sender is TEdit)) then exit;
  eb := TEdit(Sender);
  If TAccountComp.AccountTxtNumberToAccountNumber(eb.Text,an) then begin
    eb.Text := TAccountComp.AccountNumberToAccountTxtNumber(an);
  end else begin
    eb.Text := '';
  end;
  updateInfoClick(Nil);
end;

procedure TFRMOperation.ebCurrencyExit(Sender: TObject);
Var m : Int64;
  eb : TEdit;
begin
  if (Not assigned(Sender)) then exit;
  if (Not (Sender is TEdit)) then exit;
  eb := TEdit(Sender);
  If Not (eb.ReadOnly) then begin
    if Not TAccountComp.TxtToMoney(eb.Text,m) then m:=0;
    eb.Text := TAccountComp.FormatMoney(m);
    updateInfoClick(Nil);
  end;
end;

procedure TFRMOperation.ebEncryptPasswordChange(Sender: TObject);
begin
  if FDisabled then exit;
  rbEncrptedWithPassword.Checked := true;
  memoPayloadClick(Nil);
end;

procedure TFRMOperation.ebSenderAccountExit(Sender: TObject);
Var an : Cardinal;
begin
  If TAccountComp.AccountTxtNumberToAccountNumber(ebSenderAccount.Text,an) then begin
    SenderAccounts.Disable;
    try
      SenderAccounts.Clear;
      SenderAccounts.Add(an);
    finally
      SenderAccounts.Enable;
    end;
    ebSenderAccount.Text := TAccountComp.AccountNumberToAccountTxtNumber(an);
  end else begin
    if SenderAccounts.Count=1 then begin
      ebSenderAccount.Text := TAccountComp.AccountNumberToAccountTxtNumber(SenderAccounts.Get(0));
    end else begin
      ebSenderAccount.Text := '';
    end;
  end;
end;

procedure TFRMOperation.ebSenderAccountKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then ebSenderAccountExit(Nil);
end;

procedure TFRMOperation.FormCreate(Sender: TObject);
begin
  FDisabled := false;
  FWalletKeys := Nil;
  FSenderAccounts := TOrderedCardinalList.Create;
  FSenderAccounts.OnListChanged := OnSenderAccountsChanged;
  FDisabled := true;
  FNode := TNode.Node;
  ebSenderAccount.OnKeyDown:=ebAccountKeyDown;
  ebSenderAccount.Tag:=CT_AS_MyAccounts;
  ebSignerAccount.Text:='';
  ebSignerAccount.OnChange := updateInfoClick;
  ebSignerAccount.OnExit := ebAccountNumberExit;
  ebSignerAccount.OnKeyDown := ebAccountKeyDown;
  ebSignerAccount.tag := CT_AS_MyAccounts;
  sbSearchSignerAccount.OnClick := sbSearchSignerAccountClick;

  //
  lblTransactionErrors.Caption := '';
  ebDestAccount.Text := '';
  ebDestAccount.OnChange := updateInfoClick;
  ebDestAccount.OnExit := ebAccountNumberExit;
  ebDestAccount.OnKeyDown := ebAccountKeyDown;
  ebAmount.Text := TAccountComp.FormatMoney(0);
  ebAmount.OnChange := updateInfoClick;
  ebAmount.OnExit := ebCurrencyExit;
  //
  lblChangeKeyErrors.Caption := '';
  lblNewOwnerErrors.Caption := '';
  rbChangeKeyWithAnother.OnClick := updateInfoClick;
  rbChangeKeyTransferAccountToNewOwner.OnClick := updateInfoClick;
  cbNewPrivateKey.OnChange := updateInfoClick;
  //
  lblListAccountErrors.Caption := '';
  rbListAccountForPublicSale.OnClick := updateInfoClick;
  rbListAccountForPrivateSale.OnClick := updateInfoClick;
  rbListAccountForAccountSwap.OnClick := updateInfoClick;
  rbListAccountForCoinSwap.OnClick := updateInfoClick;
  ebPrice.Text := TAccountComp.FormatMoney(0);
  ebPrice.OnChange := updateInfoClick;
  ebPrice.OnExit := ebCurrencyExit;

  ebSellerAccount.Text := '';
  ebSellerAccount.OnChange := updateInfoClick;
  ebSellerAccount.OnExit := ebAccountNumberExit;
  ebSellerAccount.OnKeyDown := ebAccountKeyDown;
  ebSellerAccount.tag := CT_AS_MyAccounts;
  ebNewKey.Text := '';
  ebNewKey.OnChange := updateInfoClick;
  ebTimeLock.Text := '';
  ebTimeLock.OnChange := updateInfoClick;

  //
  lblDelistErrors.Caption := '';
  //
  lblBuyAccountErrors.Caption := '';
  ebAccountToBuy.Text := '';
  ebAccountToBuy.OnChange :=  updateInfoClick;
  ebAccountToBuy.OnExit := ebAccountNumberExit;
  ebAccountToBuy.OnKeyDown := ebAccountKeyDown;
  ebAccountToBuy.tag := CT_AS_OnlyForSale;
  ebBuyAmount.Text := TAccountComp.FormatMoney(0);
  ebBuyAmount.OnChange :=  updateInfoClick;
  ebBuyAmount.OnExit := ebCurrencyExit;
  //
  ebChangeName.OnChange:=updateInfoClick;
  ebChangeType.OnChange:=updateInfoClick;
  ebChangeAccountData.OnChange:=updateInfoClick;
  //
  sbSearchDestinationAccount.OnClick := sbSearchDestinationAccountClick;
  sbSearchListerSellerAccount.OnClick := sbSearchListerSellerAccountClick;
  btnHashLock.OnClick := sbHashLockClick;
  sbSearchBuyAccount.OnClick := sbSearchBuyAccountClick;
  //
  ebFee.Text := TAccountComp.FormatMoney(0);
  ebFee.OnExit:= ebCurrencyExit;
  memoAccounts.Lines.Clear;
  PageControlOpType.ActivePage := tsTransaction;
end;

procedure TFRMOperation.ebNewPublicKeyExit(Sender: TObject);
var errors : String;
begin
  UpdateOperationOptions(errors);
end;

procedure TFRMOperation.FormDestroy(Sender: TObject);
begin
  if Assigned(FWalletKeys) then FWalletKeys.OnChanged.Remove(OnWalletKeysChanged);
  FreeAndNil(FSenderAccounts);
end;

function TFRMOperation.GetDefaultSenderAccount: TAccount;
begin
  if FSenderAccounts.Count>=1 then Result := FNode.GetMempoolAccount( FSenderAccounts.Get(0) )
  else Result := CT_Account_NUL;
end;

procedure TFRMOperation.ebAccountKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
Var eb : TCustomEdit;
begin
  If (key <> VK_F2) then exit;
  If Not Assigned(Sender) then exit;
  if Not (Sender is TCustomEdit) then exit;
  eb := TCustomEdit(Sender);
  searchAccount(eb);
end;

procedure TFRMOperation.searchAccount(editBox: TCustomEdit);
Var F : TFRMAccountSelect;
  c : Cardinal;
begin
  F := TFRMAccountSelect.Create(Self);
  try
    F.Node := FNode;
    F.WalletKeys := FWalletKeys;
    F.Filters:=editBox.Tag;
    If TAccountComp.AccountTxtNumberToAccountNumber(editBox.Text,c) then F.DefaultAccount := c;
    F.AllowSelect:=True;
    If F.ShowModal=MrOk then begin
      editBox.Text := TAccountComp.AccountNumberToAccountTxtNumber(F.GetSelected);
    end;
  finally
    F.Free;
  end;
end;

procedure TFRMOperation.memoPayloadClick(Sender: TObject);
Var errors : String;
begin
  if SenderAccounts.Count>0 then begin
    UpdatePayload(TNode.Node.Bank.SafeBox.Account(SenderAccounts.Get(0)),errors);
  end;
end;

procedure TFRMOperation.OnSenderAccountsChanged(Sender: TObject);
Var errors : String;
begin
  if SenderAccounts.Count>1 then begin
    ebAmount.Text := 'ALL BALANCE';
    ebAmount.font.Style := [fsBold];
    ebAmount.ReadOnly := true;
  end else begin
    ebAmount.Text := TAccountComp.FormatMoney(0);
    ebAmount.ReadOnly := false;
    ebAmount.Enabled := true;
  end;
  If SenderAccounts.Count>=1 then begin
    ebSignerAccount.text := TAccountComp.AccountNumberToAccountTxtNumber(SenderAccounts.Get(0));
    ebChangeName.Text := FNode.GetMempoolAccount(SenderAccounts.Get(0)).name.ToPrintable;
    ebChangeType.Text := IntToStr(FNode.GetMempoolAccount(SenderAccounts.Get(0)).account_type);
    ebChangeAccountData.Text := FNode.GetMempoolAccount(SenderAccounts.Get(0)).account_data.ToHexaString;
  end else begin
    ebSignerAccount.text := '';
    ebChangeName.Text := '';
    ebChangeType.Text := '';
    ebChangeAccountData.Text := '';
  end;
  UpdateAccountsInfo;
  UpdateOperationOptions(errors);
end;

procedure TFRMOperation.OnWalletKeysChanged(Sender: TObject);
begin
  PostMessage(Self.Handle,CM_PC_WalletKeysChanged,0,0);
end;

procedure TFRMOperation.PageControlOpTypeChange(Sender: TObject);
var errors : String;
begin
  UpdateOperationOptions(errors);
end;

procedure TFRMOperation.sbSearchBuyAccountClick(Sender: TObject);
begin
  searchAccount(ebAccountToBuy);
end;

procedure TFRMOperation.sbSearchDestinationAccountClick(Sender: TObject);
begin
  searchAccount(ebDestAccount);
end;

procedure TFRMOperation.sbSearchListerSellerAccountClick(Sender: TObject);
begin
  searchAccount(ebSellerAccount);
end;

procedure TFRMOperation.sbSearchSignerAccountClick(Sender: TObject);
begin
  searchAccount(ebSignerAccount);
end;

procedure TFRMOperation.sbHashLockClick(Sender: TObject);
var
  LFRM : TFRMHashLock;
begin
  LFRM := TFRMHashLock.Create(Self);
  try
    case TModalResult(LFRM.ShowModal) of
      mrOK: ebHashLock.Text := TBaseType.ToRawBytes ( LFRM.HashLock ).ToHexaString;
    end;
  finally
    FreeAndNil(LFRM);
  end;
end;


procedure TFRMOperation.SetDefaultFee(const Value: Int64);
var wd : Boolean;
begin
  if FDefaultFee = Value then exit;
  wd := FDisabled;
  try
    FDisabled := true;
    FDefaultFee := Value;
    ebFee.Text := TAccountComp.FormatMoney(value);
  finally
    FDisabled := wd;
  end;
end;

procedure TFRMOperation.SetWalletKeys(const Value: TWalletKeys);
begin
  Try
    if FWalletKeys=Value then exit;
    if Assigned(FWalletKeys) then FWalletKeys.OnChanged.Remove(OnWalletKeysChanged);
    FWalletKeys := Value;
    if Assigned(FWalletKeys) then begin
      FWalletKeys.OnChanged.Add(OnWalletKeysChanged);
    end;
  Finally
    UpdateWalletKeys;
  End;
end;

procedure TFRMOperation.UpdateAccountsInfo;
Var ld : Boolean;
  i : Integer;
  balance : int64;
  acc : TAccount;
  accountstext : String;
begin
  ld := FDisabled;
  FDisabled := true;
  Try
    lblAccountCaption.Caption := 'Account';
    lblAccountsCount.Visible := false;
    lblAccountsCount.caption := inttostr(senderAccounts.Count)+' accounts';
    balance := 0;
    if SenderAccounts.Count<=0 then begin
      ebSenderAccount.Text := '';
      memoAccounts.Visible := false;
      ebSenderAccount.Visible := true;
    end else if SenderAccounts.Count=1 then begin
      ebSenderAccount.Text := TAccountComp.AccountNumberToAccountTxtNumber(SenderAccounts.Get(0));
      memoAccounts.Visible := false;
      ebSenderAccount.Visible := true;
      balance := TNode.Node.GetMempoolAccount(SenderAccounts.Get(0)).balance;
    end else begin
      // Multiple sender accounts
      lblAccountCaption.Caption := 'Accounts';
      lblAccountsCount.Visible := true;
      ebSenderAccount.Visible := false;
      accountstext := '';
      for i := 0 to SenderAccounts.Count - 1 do begin
         acc := TNode.Node.GetMempoolAccount(SenderAccounts.Get(i));
         balance := balance + acc.balance;
         if (accountstext<>'') then accountstext:=accountstext+'; ';
         accountstext := accountstext+TAccountComp.AccountNumberToAccountTxtNumber(acc.account)+' ('+TAccountComp.FormatMoney(acc.balance)+')';
      end;
      memoAccounts.Lines.Text := accountstext;
      memoAccounts.Visible := true;
    end;
    ebSenderAccount.Enabled := ebSenderAccount.Visible;
    lblAccountBalance.Caption := TAccountComp.FormatMoney(balance);
  Finally
    FDisabled := ld;
  End;
end;

function TFRMOperation.UpdateFee(var Fee: Int64; errors: String): Boolean;
begin
  errors := '';
  if trim(ebFee.Text)<>'' then begin
    Result := TAccountComp.TxtToMoney(Trim(ebFee.Text),Fee);
    if not Result then errors := 'Invalid fee value "'+ebFee.Text+'"';
  end else begin
    Fee := 0;
    Result := true;
  end;
end;

var GInUpdateInfoClick : boolean;
procedure TFRMOperation.updateInfoClick(Sender: TObject);
Var errors : String;
begin
  if NOT GInUpdateInfoClick then begin
    GInUpdateInfoClick := true;
    try
      UpdateOperationOptions(errors);
    finally
    GInUpdateInfoClick := false;
    end;
  end;
end;

function TFRMOperation.UpdateOpBuyAccount(const SenderAccount: TAccount; var AccountToBuy: TAccount; var amount: Int64; var NewPublicKey: TAccountKey; var ARecipientSigned : Boolean; var errors: String): Boolean;
var c : Cardinal;
  i : Integer;
begin
  ARecipientSigned := false;
  lblBuyAccountErrors.Caption := ''; c:=0;
  errors := '';
  Try
    if SenderAccounts.Count<>1 then begin
      errors := 'Cannot buy accounts with multioperations. Use only 1 account';
      exit;
    end;
    If (Not TAccountComp.AccountTxtNumberToAccountNumber(ebAccountToBuy.Text,c)) then begin
      errors := 'Invalid account to buy '+ebAccountToBuy.Text;
      exit;
    end;
    If (c<0) Or (c>=FNode.Bank.AccountsCount) then begin
      errors := 'Invalid account number';
      exit;
    end;
    AccountToBuy := FNode.GetMempoolAccount(c);
    ARecipientSigned := TAccountComp.IsOperationRecipientSignable(SenderAccount, AccountToBuy, Amount, FNode.Bank.BlocksCount, FNode.Bank.SafeBox.CurrentProtocol);
    if (SenderAccount.account = AccountToBuy.Account) AND (NOT ARecipientSigned) then begin
      errors := 'Not recipient signable';
      exit;
    end;

    If not TAccountComp.IsAccountForSaleOrSwap(AccountToBuy.accountInfo) then begin
      errors := 'Account '+TAccountComp.AccountNumberToAccountTxtNumber(c)+' is not for sale or swap';
      exit;
    end;
    If Not TAccountComp.TxtToMoney(ebBuyAmount.Text,amount) then begin
      errors := 'Invalid amount value';
      exit;
    end;
     if (AccountToBuy.accountInfo.price>amount) AND (NOT TAccountComp.IsAccountForCoinSwap(AccountToBuy.accountInfo)) then begin
      errors := 'Account price '+TAccountComp.FormatMoney(AccountToBuy.accountInfo.price);
      exit;
    end;
    if TAccountComp.IsAccountForSale(AccountToBuy.accountInfo) AND (amount+DefaultFee > SenderAccount.balance) then begin
      errors := 'Insufficient funds';
      exit;
    end;
    if cbBuyNewKey.ItemIndex<0 then begin
      errors := 'Must select a new private key';
      exit;
    end;
    i := PtrInt(cbBuyNewKey.Items.Objects[cbBuyNewKey.ItemIndex]);
    if (i<0) Or (i>=WalletKeys.Count) then raise Exception.Create('Invalid selected key');
    NewPublicKey := WalletKeys.Key[i].AccountKey;
    If (FNode.Bank.SafeBox.CurrentProtocol=CT_PROTOCOL_1) then begin
      errors := 'This operation needs PROTOCOL 2 active';
      exit;
    end;
  Finally
    Result := errors = '';
    lblBuyAccountErrors.Caption := errors;
  End;
end;

function TFRMOperation.UpdateOpChangeInfo(const TargetAccount: TAccount; var SignerAccount : TAccount;
   var changeName : Boolean; var newName: TRawBytes; var changeType : Boolean; var newType: Word;
   var AChangeData : Boolean; var ANewData : TRawBytes; var errors: String): Boolean;
var auxC : Cardinal;
  i : Integer;
  errCode : Integer;
begin
  Result := false;
  errors := '';
  lblChangeInfoErrors.Caption:='';
  if not (PageControlOpType.ActivePage=tsChangeInfo) then exit;
  try
    if (TAccountComp.IsAccountLocked(TargetAccount.accountInfo,FNode.Bank.BlocksCount)) then begin
      errors := 'Account '+TAccountComp.AccountNumberToAccountTxtNumber(TargetAccount.account)+' is locked until block '+IntToStr(TargetAccount.accountInfo.locked_until_block);
      exit;
    end;
    // Signer:
    if SenderAccounts.Count=1 then begin
      If Not TAccountComp.AccountTxtNumberToAccountNumber(ebSignerAccount.Text,auxC) then begin
        errors := 'Invalid signer account';
        exit;
      end;
    end else begin
       auxC := TargetAccount.account;
    end;
    if (auxC<0) Or (auxC >= FNode.Bank.AccountsCount) then begin
      errors := 'Signer account does not exists '+TAccountComp.AccountNumberToAccountTxtNumber(auxC);
      exit;
    end;
    SignerAccount := FNode.GetMempoolAccount(auxC);
    if (TAccountComp.IsAccountLocked(SignerAccount.accountInfo,FNode.Bank.BlocksCount)) then begin
      errors := 'Signer account '+TAccountComp.AccountNumberToAccountTxtNumber(SignerAccount.account)+' is locked until block '+IntToStr(SignerAccount.accountInfo.locked_until_block);
      exit;
    end;
    if (Not TAccountComp.EqualAccountKeys(SignerAccount.accountInfo.accountKey,TargetAccount.accountInfo.accountKey)) then begin
      errors := 'Signer account '+TAccountComp.AccountNumberToAccountTxtNumber(SignerAccount.account)+' is not ower of account '+TAccountComp.AccountNumberToAccountTxtNumber(TargetAccount.account);
      exit;
    end;
    If (FNode.Bank.SafeBox.CurrentProtocol=CT_PROTOCOL_1) then begin
      errors := 'This operation needs PROTOCOL 2 active';
      exit;
    end;
    // New name and type (only when single operation)
    If (SenderAccounts.Count=1) then begin
      newName.FromString(LowerCase( Trim(ebChangeName.Text) ));
      If Not TBaseType.Equals(newName,TargetAccount.name) then begin
        changeName:=True;
        If Length(newName)>0 then begin
          if (Not TPCSafeBox.ValidAccountName(newName,errors)) then begin
            errors := '"'+newName.ToPrintable+'" is not a valid name: '+errors;
            Exit;
          end;
          i := (FNode.Bank.SafeBox.FindAccountByName(newName));
          if (i>=0) then begin
            errors := 'Name "'+newName.ToPrintable+'" is used by account '+TAccountComp.AccountNumberToAccountTxtNumber(i);
            Exit;
          end;
        end;
      end else changeName := False;
    end else changeName := False;
    val(ebChangeType.Text,newType,errCode);
    if (errCode>0) then begin
      errors := 'Invalid type '+ebChangeType.text;
      Exit;
    end;
    changeType := TargetAccount.account_type<>newType;
    //
    If (SenderAccounts.Count=1) And (newName=TargetAccount.name) And (newType=TargetAccount.account_type) then begin
      errors := 'Account name and type are the same. Not changed';
      Exit;
    end;
    if FNode.Bank.SafeBox.CurrentProtocol>=CT_PROTOCOL_5 then begin
      // Allow Change Account.Data PIP-0024
      if Not TCrypto.HexaToRaw(ebChangeAccountData.Text,ANewData) then begin
        errors := 'Invalid hexadecimal value at Data';
        Exit;
      end;
      AChangeData := Not TBaseType.Equals( TargetAccount.account_data , ANewData);
      if Length(ANewData)>CT_MaxAccountDataSize then begin
        errors := Format('Data size (%d) greater than %d',[Length(ANewData),CT_MaxAccountDataSize]);
        Exit;
      end;
    end;
  finally
    Result := errors = '';
    if Not Result then begin
      lblChangeInfoErrors.Font.Color := clRed;
      lblChangeInfoErrors.Caption := errors;
    end else begin
      lblChangeInfoErrors.Font.Color := clGreen;
      If (SenderAccounts.Count=1) then
        lblChangeInfoErrors.Caption := TAccountComp.AccountNumberToAccountTxtNumber(TargetAccount.account)+' can be updated'
      else lblChangeInfoErrors.Caption := IntToStr(SenderAccounts.Count)+' accounts can be updated'
    end;
  end;
end;

function TFRMOperation.UpdateOpChangeKey(Const TargetAccount : TAccount; var SignerAccount : TAccount; var NewPublicKey: TAccountKey; var errors: String): Boolean;
var i : Integer;
  auxC : Cardinal;
begin
  Result := false;
  errors := '';
  lblChangeKeyErrors.Caption := '';
  lblNewOwnerErrors.Caption := '';
  if not (PageControlOpType.ActivePage=tsChangePrivateKey) then exit;
  try
    if rbChangeKeyWithAnother.Checked then begin
      if cbNewPrivateKey.ItemIndex<0 then begin
        errors := 'Must select a new private key';
        lblChangeKeyErrors.Caption := errors;
        exit;
      end;
      i := PtrInt(cbNewPrivateKey.Items.Objects[cbNewPrivateKey.ItemIndex]);
      if (i<0) Or (i>=WalletKeys.Count) then raise Exception.Create('Invalid selected key');
      NewPublicKey := WalletKeys.Key[i].AccountKey;
    end else if rbChangeKeyTransferAccountToNewOwner.Checked then begin
      If Not TAccountComp.AccountKeyFromImport(ebNewPublicKey.Text,NewPublicKey,errors) then begin
        lblNewOwnerErrors.Caption := errors;
        lblNewOwnerErrors.Font.Color := clRed;
        exit;
      end else begin
        lblNewOwnerErrors.Caption := 'New key type: '+TAccountComp.GetECInfoTxt(NewPublicKey.EC_OpenSSL_NID);
        lblNewOwnerErrors.Font.Color := clGreen;
      end;
    end else begin
      errors := 'Select a change type';
      lblChangeKeyErrors.Caption := errors;
      exit;
    end;
    If FNode.Bank.SafeBox.CurrentProtocol>=1 then begin
      // Signer:
      If Not TAccountComp.AccountTxtNumberToAccountNumber(ebSignerAccount.Text,auxC) then begin
        errors := 'Invalid signer account';
        exit;
      end;
      if (auxC<0) Or (auxC >= FNode.Bank.AccountsCount) then begin
        errors := 'Signer account does not exists '+TAccountComp.AccountNumberToAccountTxtNumber(auxC);
        exit;
      end;
      SignerAccount := FNode.GetMempoolAccount(auxC);
      if (TAccountComp.IsAccountLocked(SignerAccount.accountInfo,FNode.Bank.BlocksCount)) then begin
        errors := 'Signer account '+TAccountComp.AccountNumberToAccountTxtNumber(SignerAccount.account)+' is locked until block '+IntToStr(SignerAccount.accountInfo.locked_until_block);
        exit;
      end;
      if (Not TAccountComp.EqualAccountKeys(SignerAccount.accountInfo.accountKey,TargetAccount.accountInfo.accountKey)) then begin
        errors := 'Signer account '+TAccountComp.AccountNumberToAccountTxtNumber(SignerAccount.account)+' is not ower of account '+TAccountComp.AccountNumberToAccountTxtNumber(TargetAccount.account);
        exit;
      end;
    end else SignerAccount := TargetAccount;
    if (TAccountComp.EqualAccountKeys(TargetAccount.accountInfo.accountKey,NewPublicKey)) then begin
      errors := 'New public key is the same public key';
      lblChangeKeyErrors.Caption := errors;
      lblNewOwnerErrors.Caption := errors;
      exit;
    end;
  finally
    Result := errors = '';
  end;
end;

function TFRMOperation.UpdateOpDelist(const TargetAccount : TAccount; var SignerAccount : TAccount; var errors: String): Boolean;
Var auxC : Cardinal;
begin
  lblDelistErrors.Caption := '';
  errors := '';
  Result := false;
  if not (PageControlOpType.ActivePage=tsDelistAccount) then exit;
  try
    if Not TAccountComp.IsAccountForSaleOrSwap(TargetAccount.accountInfo) then begin
      errors := 'Account '+TAccountComp.AccountNumberToAccountTxtNumber(TargetAccount.account)+' is not for sale or swap';
      exit;
    end;
    if (TAccountComp.IsAccountLocked(TargetAccount.accountInfo,FNode.Bank.BlocksCount)) then begin
      errors := 'Account '+TAccountComp.AccountNumberToAccountTxtNumber(TargetAccount.account)+' is locked until block '+IntToStr(TargetAccount.accountInfo.locked_until_block);
      exit;
    end;
    // Signer:
    If Not TAccountComp.AccountTxtNumberToAccountNumber(ebSignerAccount.Text,auxC) then begin
      errors := 'Invalid signer account';
      exit;
    end;
    if (auxC<0) Or (auxC >= FNode.Bank.AccountsCount) then begin
      errors := 'Signer account does not exists '+TAccountComp.AccountNumberToAccountTxtNumber(auxC);
      exit;
    end;
    SignerAccount := FNode.GetMempoolAccount(auxC);
    if (TAccountComp.IsAccountLocked(SignerAccount.accountInfo,FNode.Bank.BlocksCount)) then begin
      errors := 'Signer account '+TAccountComp.AccountNumberToAccountTxtNumber(SignerAccount.account)+' is locked until block '+IntToStr(SignerAccount.accountInfo.locked_until_block);
      exit;
    end;
    if (Not TAccountComp.EqualAccountKeys(SignerAccount.accountInfo.accountKey,TargetAccount.accountInfo.accountKey)) then begin
      errors := 'Signer account '+TAccountComp.AccountNumberToAccountTxtNumber(SignerAccount.account)+' is not ower of delisted account '+TAccountComp.AccountNumberToAccountTxtNumber(TargetAccount.account);
      exit;
    end;
    If (FNode.Bank.SafeBox.CurrentProtocol=CT_PROTOCOL_1) then begin
      errors := 'This operation needs PROTOCOL 2 active';
      exit;
    end;
  finally
    Result := errors = '';
    if Not Result then begin
      lblDelistErrors.Font.Color := clRed;
      lblDelistErrors.Caption := errors;
    end else begin
      lblDelistErrors.Font.Color := clGreen;
      lblDelistErrors.Caption := TAccountComp.AccountNumberToAccountTxtNumber(TargetAccount.account)+' can be delisted';
    end;
  end;
end;

function TFRMOperation.UpdateOperationOptions(var errors : String) : Boolean;
Var
  iWallet,iAcc : Integer;
  wk : TWalletKey;
  e : String;
  sender_account,dest_account,seller_account, account_to_buy, signer_account : TAccount;
  publicKey : TAccountKey;
  LHashLock : T32Bytes;
  salePrice, amount : Int64;
  auxC : Cardinal;
  changeName,changeType, LRecipientSigned, LChangeAccountData : Boolean;
  newName, LNewAccountData : TRawBytes;
  newType : Word;
begin
  Result := false;
  sender_account := CT_Account_NUL;
  errors := '';
  if Not UpdateFee(FDefaultFee,errors) then exit;
  try
    bbPassword.Visible := false;
    bbPassword.Enabled := false;
    if Not Assigned(WalletKeys) then begin
      errors := 'No wallet keys';
      lblGlobalErrors.Caption := errors;
      exit;
    end;
    if SenderAccounts.Count=0 then begin
      errors := 'No sender account';
      lblGlobalErrors.Caption := errors;
      exit;
    end else begin
      for iAcc := 0 to SenderAccounts.Count - 1 do begin
        sender_account := TNode.Node.Bank.SafeBox.Account(SenderAccounts.Get(iAcc));
        iWallet := WalletKeys.IndexOfAccountKey(sender_account.accountInfo.accountKey);
        if (iWallet<0) then begin
          errors := 'Private key of account '+TAccountComp.AccountNumberToAccountTxtNumber(sender_account.account)+' not found in wallet';
          lblGlobalErrors.Caption := errors;
          exit;
        end;
        wk := WalletKeys.Key[iWallet];
        if not assigned(wk.PrivateKey) then begin
          if Length(wk.CryptedKey)>0 then begin
            errors := 'Wallet is password protected. Need password';
            bbPassword.Visible := true;
            bbPassword.Enabled := true;
          end else begin
            errors := 'Only public key of account '+TAccountComp.AccountNumberToAccountTxtNumber(sender_account.account)+' found in wallet. You cannot operate with this account';
          end;
          lblGlobalErrors.Caption := errors;
          exit;
        end;
      end;
    end;
    lblGlobalErrors.Caption := '';
  Finally
    if lblGlobalErrors.Caption<>'' then begin
      tsGlobalError.visible := true;
      tsGlobalError.tabvisible := {$IFDEF unix}true{$ELSE}false{$ENDIF};
      tsOperation.TabVisible := false;
      PageControlLocked.ActivePage := tsGlobalError;
      if bbPassword.CanFocus then begin
        ActiveControl := bbPassword;
      end;
    end else begin
      tsOperation.visible := true;
      tsOperation.tabvisible := {$IFDEF unix}true{$ELSE}false{$ENDIF};
      tsGlobalError.TabVisible := false;
      PageControlLocked.ActivePage := tsOperation;
    end;
  End;
  if (PageControlOpType.ActivePage = tsTransaction) then begin
    Result := UpdateOpTransaction(GetDefaultSenderAccount,dest_account,amount,errors);
  end else if (PageControlOpType.ActivePage = tsChangePrivateKey) then begin
    Result := UpdateOpChangeKey(GetDefaultSenderAccount,signer_account,publicKey,errors);
  end else if (PageControlOpType.ActivePage = tsListAccount) then begin
    Result := UpdateOpListAccount(GetDefaultSenderAccount,salePrice,seller_account,signer_account,publicKey,auxC,LHashLock,errors);
  end else if (PageControlOpType.ActivePage = tsDelistAccount) then begin
    Result := UpdateOpDelist(GetDefaultSenderAccount,signer_account,errors);
  end else if (PageControlOpType.ActivePage = tsBuyAccount) then begin
    Result := UpdateOpBuyAccount(GetDefaultSenderAccount,account_to_buy,amount,publicKey,LRecipientSigned, errors);
  end else if (PageControlOpType.ActivePage = tsChangeInfo) then begin
    Result := UpdateOpChangeInfo(GetDefaultSenderAccount,signer_account,changeName,newName,changeType,newType,LChangeAccountData,LNewAccountData,errors);
  end else begin
    errors := 'Must select an operation';
  end;
  if (PageControlOpType.ActivePage=tsTransaction) then begin
    rbEncryptedWithOldEC.Caption := 'Encrypted with sender public key';
    rbEncryptedWithEC.Caption := 'Encrypted with destination public key';
  end else if (PageControlOpType.ActivePage=tsChangePrivateKey) then begin
    rbEncryptedWithOldEC.Caption := 'Encrypted with old public key';
    rbEncryptedWithEC.Caption := 'Encrypted with new public key';
  end else if ((PageControlOpType.ActivePage=tsListAccount) Or (PageControlOpType.ActivePage=tsDelistAccount)) then begin
    rbEncryptedWithOldEC.Caption := 'Encrypted with target public key';
    rbEncryptedWithEC.Caption := 'Encrypted with signer public key';
  end else if (PageControlOpType.ActivePage=tsBuyAccount) then begin
    rbEncryptedWithOldEC.Caption := 'Encrypted with buyer public key';
    rbEncryptedWithEC.Caption := 'Encrypted with target public key';
  end;
  ebSignerAccount.Enabled:= ((PageControlOpType.ActivePage=tsChangePrivateKey) And (FNode.Bank.SafeBox.CurrentProtocol>=CT_PROTOCOL_2))
    Or ((PageControlOpType.ActivePage=tsChangeInfo) And (SenderAccounts.Count=1))
    Or (PageControlOpType.ActivePage=tsListAccount)
    Or (PageControlOpType.ActivePage=tsDelistAccount);
  sbSearchSignerAccount.Enabled:=ebSignerAccount.Enabled;
  lblSignerAccount.Enabled := ebSignerAccount.Enabled;
  lblChangeName.Enabled:= (PageControlOpType.ActivePage=tsChangeInfo) And (SenderAccounts.Count=1);
  ebChangeName.Enabled:= lblChangeName.Enabled;
  //
  UpdatePayload(sender_account, e);
end;

function TFRMOperation.UpdateOpListAccount(const TargetAccount: TAccount;
  var SalePrice: Int64; var SellerAccount, SignerAccount: TAccount;
  var NewOwnerPublicKey: TAccountKey; var LockedUntilBlock: Cardinal;
  var HashLock : T32Bytes; var errors: String): Boolean;
var auxC : Cardinal; LBytes : TBytes;
begin
  Result := False;
  SalePrice := 0; SellerAccount := CT_Account_NUL;
  NewOwnerPublicKey := CT_TECDSA_Public_Nul;
  LockedUntilBlock := 0; errors := '';
  if (PageControlOpType.ActivePage <> tsListAccount) then exit;
  lblListAccountErrors.Caption := '';
  Try
    if (rbListAccountForPublicSale.Checked) Or (rbListAccountForPrivateSale.Checked) then begin
      {%region 'List Account Options'}
      lblPrice.Visible := true;
      lblPrice.Caption := 'Sale Price';
      lblPrice.Enabled := true;
      ebPrice.Visible := true;
      ebPrice.Enabled := true;
      lblNewKey.Visible := true;
      lblNewKey.Enabled := true;
      lblNewKey.Caption := 'Buyer Key';
      ebNewKey.Visible := true;
      ebNewKey.Enabled := true;
      lblSeller.Visible := true;
      lblSeller.Caption := 'Seller Account';
      ebSellerAccount.Visible := true;
      sbSearchListerSellerAccount.Visible := true;
      lblTimeLock.Visible := true;
      ebTimeLock.Visible := true;
      sbTimeLock.Visible := true;
      lblHashLock.Visible := false;
      ebHashLock.Visible := false;
      btnHashLock.Visible := false;
      btnHashLock.Enabled := false;
      if rbListAccountForPublicSale.Checked then begin
        lblNewKey.Enabled := false;
        ebNewKey.Enabled := false;
        ebTimeLock.Enabled := false;
        lblTimeLock.Enabled := false;
      end else if rbListAccountForPrivateSale.Checked then begin
        lblNewKey.Enabled := true;
        ebNewKey.Enabled := true;
        ebTimeLock.Enabled := true;
        lblTimeLock.Enabled := true;
      end;
      if not TAccountComp.TxtToMoney(ebPrice.Text,salePrice) then begin
        errors := 'Invalid price';
        exit;
      end;
      // Signer:
      If Not TAccountComp.AccountTxtNumberToAccountNumber(ebSignerAccount.Text,auxC) then begin
        errors := 'Invalid signer account';
        exit;
      end;
      if (auxC<0) Or (auxC >= FNode.Bank.AccountsCount) then begin
        errors := 'Signer account does not exists '+TAccountComp.AccountNumberToAccountTxtNumber(auxC);
        exit;
      end;
      SignerAccount := FNode.GetMempoolAccount(auxC);
      // Seller
      If Not TAccountComp.AccountTxtNumberToAccountNumber(ebSellerAccount.Text,auxC) then begin
        errors := 'Invalid seller account';
        exit;
      end;
      if (auxC<0) Or (auxC >= FNode.Bank.AccountsCount) then begin
        errors := 'Seller account does not exists '+TAccountComp.AccountNumberToAccountTxtNumber(auxC);
        exit;
      end;
      if (auxC=TargetAccount.account) then begin
        errors := 'Seller account cannot be same account';
        exit;
      end;

      SellerAccount := FNode.GetMempoolAccount(auxC);
      if rbListAccountForPrivateSale.Checked then begin
        lblNewKey.Visible := true;
        lblNewKey.Enabled := true;
        ebNewKey.Visible := true;
        ebNewKey.Enabled := true;
        ebTimeLock.Enabled := true;
        lblTimeLock.Enabled := true;
        If Not TAccountComp.AccountKeyFromImport(ebNewKey.Text,NewOwnerPublicKey,errors) then begin
          errors := 'Public key: '+errors;
          exit;
        end else begin
          lblListAccountErrors.Font.Color := clGreen;
          lblListAccountErrors.Caption := 'New key type: '+TAccountComp.GetECInfoTxt(NewOwnerPublicKey.EC_OpenSSL_NID);
        end;
        if TAccountComp.EqualAccountKeys(NewOwnerPublicKey,TargetAccount.accountInfo.accountKey) then begin
          errors := 'New public key for private sale is the same public key';
          Exit;
        end;
        LockedUntilBlock := StrToIntDef(ebTimeLock.Text,0);
        if LockedUntilBlock=0 then begin
          errors := 'Insert locking block';
          exit;
        end;
      end;
      If (FNode.Bank.SafeBox.CurrentProtocol=CT_PROTOCOL_1) then begin
        errors := 'This operation needs PROTOCOL 2 active';
        exit;
      end;
    {%endregion}
    end else if (rbListAccountForAccountSwap.Checked) Or (rbListAccountForCoinSwap.Checked) then begin
      {%region 'Atomic Swap Options'}
      lblPrice.Visible := true;
      ebPrice.Visible := true;
      lblNewKey.Visible := true;
      ebNewKey.Visible := true;
      lblTimeLock.Visible := true;
      lblTimeLock.Enabled := true;
      ebTimeLock.Visible := true;
      ebTimeLock.Enabled := true;
      sbTimeLock.Visible := true;
      sbTimeLock.Enabled := true;
      lblHashLock.Visible := true;
      ebHashLock.Visible := true;
      btnHashLock.Visible := true;
      btnHashLock.Enabled := true;

      if rbListAccountForAccountSwap.Checked then begin
        lblSeller.Visible := False;
        ebSellerAccount.Visible := False;
        sbSearchListerSellerAccount.Visible := false;
        lblNewKey.Caption := 'Counterparty Key';
        lblNewKey.Visible := true;
        lblNewKey.Enabled := true;
        ebNewKey.Visible := true;
        ebNewKey.Enabled := true;
        lblPrice.Visible := false;
        lblPrice.Enabled := false;
        ebPrice.Enabled := false;
        ebPrice.Visible := false;
      end else if rbListAccountForCoinSwap.Checked then begin
        lblSeller.Visible := true;
        lblSeller.Caption := 'Counterparty Account';
        ebSellerAccount.Visible := true;
        sbSearchListerSellerAccount.Visible := true;
        lblNewKey.Visible := false;
        ebNewKey.Visible := false;
        lblPrice.Visible := true;
        lblPrice.Caption := 'Swap Amount';
        lblPrice.Enabled := true;
        ebPrice.Visible := true;
        ebPrice.Enabled := true;
      end;

      // COMMON SWAP VALDATION
      // V5 Check
      If (FNode.Bank.SafeBox.CurrentProtocol<CT_PROTOCOL_5) then begin
        errors := 'This operation needs PROTOCOL 5 or greater';
        exit;
      end;

      // Signer
      If Not TAccountComp.AccountTxtNumberToAccountNumber(ebSignerAccount.Text,auxC) then begin
        errors := 'Invalid signer account';
        exit;
      end;
      if (auxC<0) Or (auxC >= FNode.Bank.AccountsCount) then begin
        errors := 'Signer account does not exists '+TAccountComp.AccountNumberToAccountTxtNumber(auxC);
        exit;
      end;
      SignerAccount := FNode.GetMempoolAccount(auxC);

      // Time-Lock
      LockedUntilBlock := StrToIntDef(ebTimeLock.Text,0);
      if LockedUntilBlock=0 then begin
        errors := 'Insert locking block';
        exit;
      end;

      // Hash-Lock
      HashLock := CT_HashLock_NUL;
      if (NOT TCrypto.HexaToRaw(ebHashLock.Text, LBytes)) OR (Length(LBytes) <> 32) then begin
        errors := 'Hash-Lock is required (32byte hexstring)';
        exit;
      end;
      HashLock := TBaseType.To32Bytes(LBytes);

      // Account Swap Validation
      if rbListAccountForAccountSwap.Checked then begin
        // Sale price is 0
        SalePrice := 0;

        // Counterparty key
        If Not TAccountComp.AccountKeyFromImport(ebNewKey.Text,NewOwnerPublicKey,errors) then begin
          errors := 'Counterparty Key: '+errors;
          exit;
        end else begin
          lblListAccountErrors.Font.Color := clGreen;
          lblListAccountErrors.Caption := 'New key type: '+TAccountComp.GetECInfoTxt(NewOwnerPublicKey.EC_OpenSSL_NID);
        end;
        if TAccountComp.EqualAccountKeys(NewOwnerPublicKey,TargetAccount.accountInfo.accountKey) then begin
          errors := 'New public key for private sale is the same public key';
          Exit;
        end;

        // Seller account is target account (but price is 0, never receives)
        SellerAccount := TargetAccount;
      end else if (rbListAccountForCoinSwap.Checked) then begin
        // Coin Swap Validation
        // Price
        IF NOT TAccountComp.TxtToMoney(ebPrice.Text,salePrice) then begin
          errors := 'Invalid swap amount';
          exit;
        end;

        // Counterparty Account (Seller variable)
        If Not TAccountComp.AccountTxtNumberToAccountNumber(ebSellerAccount.Text,auxC) then begin
          errors := 'Invalid counterparty account';
          exit;
        end;
        if (auxC<0) Or (auxC >= FNode.Bank.AccountsCount) then begin
          errors := 'Counterparty account does not exists '+TAccountComp.AccountNumberToAccountTxtNumber(auxC);
          exit;
        end;
        if (auxC=TargetAccount.account) then begin
          errors := 'Counterparty account cannot be same account';
          exit;
        end;
        SellerAccount := FNode.GetMempoolAccount(auxC);

        // New Owner Public Key is the same public key
        NewOwnerPublicKey := TargetAccount.accountInfo.accountKey;
      end;

    {%endregion}
    end else begin
      lblPrice.Visible := false;
      ebPrice.Visible := false;
      lblNewKey.Visible := false;
      ebNewKey.Visible := false;
      lblSeller.Visible := false;
      ebSellerAccount.Visible := false;
      sbSearchListerSellerAccount.Visible := false;
      lblTimeLock.Visible := false;
      ebTimeLock.Visible := false;
      sbTimeLock.Visible := false;
      lblHashLock.Visible := false;
      ebHashLock.Visible := false;
      btnHashLock.Visible := false;
      btnHashLock.Enabled := false;
      errors := 'Select a sale type';
      exit;
    end;
  Finally
    Result := errors='';
    if errors<>'' then begin
      lblListAccountErrors.Caption := errors;
      lblListAccountErrors.Font.Color := clRed;
    end;
  End;
end;

function TFRMOperation.UpdateOpTransaction(const SenderAccount: TAccount;  var DestAccount: TAccount; var amount: Int64;  var errors: String): Boolean;
Var c : Cardinal;
begin
  Result := False;
  errors := '';
  lblTransactionErrors.Caption := '';
  if PageControlOpType.ActivePage<>tsTransaction then exit;
  if not (TAccountComp.AccountTxtNumberToAccountNumber(ebDestAccount.Text,c)) then begin
    errors := 'Invalid dest. account ('+ebDestAccount.Text+')';
    lblTransactionErrors.Caption := errors;
    exit;
  end;
  if (c<0) Or (c>=TNode.Node.Bank.AccountsCount) then begin
    errors := 'Invalid dest. account ('+TAccountComp.AccountNumberToAccountTxtNumber(c)+')';
    lblTransactionErrors.Caption := errors;
    exit;
  end;
  DestAccount := TNode.Node.GetMempoolAccount(c);
  if SenderAccounts.Count=1 then begin
    if not TAccountComp.TxtToMoney(ebAmount.Text,amount) then begin
      errors := 'Invalid amount ('+ebAmount.Text+')';
      lblTransactionErrors.Caption := errors;
      exit;
    end;
  end else amount := 0; // ALL BALANCE
  if DestAccount.account=SenderAccount.account then begin
    errors := 'Sender and dest account are the same';
    lblTransactionErrors.Caption := errors;
    exit;
  end;
  if (SenderAccounts.Count=1) then begin
    if (SenderAccount.balance<(amount+FDefaultFee)) then begin
       errors := 'Insufficient funds';
       lblTransactionErrors.Caption := errors;
       exit;
    end;
  end;
  Result := True;
end;

function TFRMOperation.UpdatePayload(const SenderAccount: TAccount;
  var errors: String): Boolean;
Var payload_u : AnsiString;
  payload_encrypted : TRawBytes;
  account : TAccount;
  public_key : TAccountKey;
  dest_account_number : Cardinal;
  i : Integer;
  valid : Boolean;
  wk : TWalletKey;
  LPayloadBytes : TRawBytes;
begin
  valid := false;
  payload_encrypted := Nil;
  FEncodedPayload := Nil;
  errors := 'Unknown error';
  payload_u := memoPayload.Lines.Text;
  try
    if (payload_u='') then begin
      valid := true;
      exit;
    end;
    if cbPayloadAsHex.Checked then begin
      if NOT TCrypto.HexaToRaw(payload_u, LPayloadBytes) then begin
        valid := false;
        errors := 'Payload not hex-formatted';
        exit;
      end;
    end else LPayloadBytes := TEncoding.ANSI.GetBytes(payload_u);

    if (rbEncryptedWithOldEC.Checked) then begin
      // Use sender
      errors := 'Error encrypting';
      account := FNode.GetMempoolAccount(SenderAccount.account);
      TPCEncryption.DoPascalCoinECIESEncrypt(account.accountInfo.accountKey,LPayloadBytes,payload_encrypted);
      valid := Length(payload_encrypted)>0;
    end else if (rbEncryptedWithEC.Checked) then begin
      errors := 'Error encrypting';
      if (PageControlOpType.ActivePage=tsTransaction) or (PageControlOpType.ActivePage=tsListAccount) or (PageControlOpType.ActivePage=tsDelistAccount)
        or (PageControlOpType.ActivePage=tsBuyAccount) then begin
        // With dest public key
        If (PageControlOpType.ActivePage=tsTransaction) then begin
          If Not TAccountComp.AccountTxtNumberToAccountNumber(ebDestAccount.Text,dest_account_number) then begin
            errors := 'Invalid dest account number';
            exit;
          end;
        end else if (PageControlOpType.ActivePage=tsListAccount) then begin
          If Not TAccountComp.AccountTxtNumberToAccountNumber(ebSignerAccount.Text,dest_account_number) then begin
            errors := 'Invalid signer account number';
            exit;
          end;
        end else if (PageControlOpType.ActivePage=tsDelistAccount) then begin
          If Not TAccountComp.AccountTxtNumberToAccountNumber(ebSignerAccount.Text,dest_account_number) then begin
            errors := 'Invalid signer account number';
            exit;
          end;
        end else if (PageControlOpType.ActivePage=tsBuyAccount) then begin
          If Not TAccountComp.AccountTxtNumberToAccountNumber(ebAccountToBuy.Text,dest_account_number) then begin
            errors := 'Invalid account to buy number';
            exit;
          end;
        end else begin
          errors := 'ERROR DEV 20170512-1';
          exit;
        end;
        if (dest_account_number<0) or (dest_account_number>=FNode.Bank.AccountsCount) then begin
          errors := 'Invalid payload encrypted account number: '+TAccountComp.AccountNumberToAccountTxtNumber(dest_account_number);
          exit;
        end;
        account := FNode.GetMempoolAccount(dest_account_number);
        TPCEncryption.DoPascalCoinECIESEncrypt(account.accountInfo.accountKey,LPayloadBytes,payload_encrypted);
        valid := Length(payload_encrypted)>0;
      end else if (PageControlOpType.ActivePage=tsChangePrivateKey) then begin
        if (rbChangeKeyWithAnother.Checked) then begin
          // With new key generated
          if (cbNewPrivateKey.ItemIndex>=0) then begin
            i := PtrInt(cbNewPrivateKey.Items.Objects[cbNewPrivateKey.ItemIndex]);
            if (i>=0) then public_key := WalletKeys.Key[i].AccountKey;
          end else begin
            errors := 'Must select a private key';
            exit;
          end;
        end else if (rbChangeKeyTransferAccountToNewOwner.Checked) then begin
          If Not TAccountComp.AccountKeyFromImport(ebNewPublicKey.Text,public_key,errors) then begin
            errors := 'Public key: '+errors;
            exit;
          end;
        end else begin
          errors := 'Must select change type';
          exit;
        end;
        if public_key.EC_OpenSSL_NID<>CT_Account_NUL.accountInfo.accountKey.EC_OpenSSL_NID then begin
          TPCEncryption.DoPascalCoinECIESEncrypt(public_key,LPayloadBytes,payload_encrypted);
          valid := Length(payload_encrypted)>0;
        end else begin
          valid := false;
          errors := 'Selected private key is not valid to encode';
          exit;
        end;
      end else begin
        errors := 'This operation does not allow this kind of payload';
      end;
    end else if (rbEncrptedWithPassword.Checked) then begin
      payload_encrypted := TPCEncryption.DoPascalCoinAESEncrypt(LPayloadBytes,TEncoding.ANSI.GetBytes(ebEncryptPassword.Text));
      valid := Length(payload_encrypted)>0;
    end else if (rbNotEncrypted.Checked) then begin
      payload_encrypted := LPayloadBytes;
      valid := true;
    end else begin
      errors := 'Must select an encryption option for payload';
    end;
  finally
    if valid then begin
      if length(payload_encrypted)>CT_MaxPayloadSize then begin
        valid := false;
        errors := 'Payload size is bigger than '+inttostr(CT_MaxPayloadSize)+' ('+Inttostr(length(payload_encrypted))+')';
      end;
    end;
    if valid then begin
      lblEncryptionErrors.Caption := '';
      lblPayloadLength.Caption := Format('(%db -> %db)',[length(payload_u),length(payload_encrypted)]);
    end else begin
      lblEncryptionErrors.Caption := errors;
      lblPayloadLength.Caption := Format('(%db -> ?)',[length(payload_u)]);
    end;
    FEncodedPayload := payload_encrypted;
    Result := valid;
  end;
end;

procedure TFRMOperation.UpdateWalletKeys;
Var i : Integer;
  wk : TWalletKey;
  s : String;
begin
  cbNewPrivateKey.items.BeginUpdate;
  cbBuyNewKey.Items.BeginUpdate;
  Try
    cbNewPrivateKey.Items.Clear;
    cbBuyNewKey.Items.Clear;
    if Not Assigned(FWalletKeys) then exit;
    For i:=0 to FWalletKeys.Count-1 do begin
      wk := FWalletKeys.Key[i];
      if (wk.Name='') then begin
        s := TCrypto.ToHexaString( TAccountComp.AccountKey2RawString(wk.AccountKey));
      end else begin
        s := wk.Name;
      end;
      if Not Assigned(wk.PrivateKey) then s := s + '(*)';
      cbNewPrivateKey.Items.AddObject(s,TObject(i));
      cbBuyNewKey.Items.AddObject(s,TObject(i));
    end;
    cbNewPrivateKey.Sorted := true;
    cbBuyNewKey.Sorted := true;
  Finally
    cbNewPrivateKey.Items.EndUpdate;
    cbBuyNewKey.Items.EndUpdate;
  End;
  updateInfoClick(Nil);
  memoPayloadClick(Nil);
end;

end.
