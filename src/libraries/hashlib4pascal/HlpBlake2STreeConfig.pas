unit HlpBlake2STreeConfig;

{$I HashLib.inc}

interface

uses
  HlpIBlake2STreeConfig,
  HlpHashLibTypes;

resourcestring
  SInvalidFanOutParameter =
    'FanOut Value Should be Between [0 .. 255] for Blake2S';
  SInvalidMaxDepthParameter =
    'FanOut Value Should be Between [1 .. 255] for Blake2S';
  SInvalidNodeDepthParameter =
    'NodeDepth Value Should be Between [0 .. 255] for Blake2S';
  SInvalidInnerHashSizeParameter =
    'InnerHashSize Value Should be Between [0 .. 32] for Blake2S';
  SInvalidNodeOffsetParameter =
    'NodeOffset Value Should be Between [0 .. (2^48-1)] for Blake2S';

type

  TBlake2STreeConfig = class sealed(TInterfacedObject, IBlake2STreeConfig)

  strict private
  var
    FFanOut, FMaxDepth, FNodeDepth, FInnerHashSize: Byte;
    FLeafSize: UInt32;
    FNodeOffset: UInt64;
    FIsLastNode: Boolean;

    procedure ValidateFanOut(AFanOut: Byte); inline;
    procedure ValidateInnerHashSize(AInnerHashSize: Byte); inline;
    procedure ValidateMaxDepth(AMaxDepth: Byte); inline;
    procedure ValidateNodeDepth(ANodeDepth: Byte); inline;
    procedure ValidateNodeOffset(ANodeOffset: UInt64); inline;

    function GetFanOut: Byte; inline;
    procedure SetFanOut(AValue: Byte); inline;

    function GetMaxDepth: Byte; inline;
    procedure SetMaxDepth(AValue: Byte); inline;

    function GetNodeDepth: Byte; inline;
    procedure SetNodeDepth(AValue: Byte); inline;

    function GetInnerHashSize: Byte; inline;
    procedure SetInnerHashSize(AValue: Byte); inline;

    function GetLeafSize: UInt32; inline;
    procedure SetLeafSize(AValue: UInt32); inline;

    function GetNodeOffset: UInt64; inline;
    procedure SetNodeOffset(AValue: UInt64); inline;

    function GetIsLastNode: Boolean; inline;
    procedure SetIsLastNode(AValue: Boolean); inline;

  public
    constructor Create();

    property FanOut: Byte read GetFanOut write SetFanOut;

    property MaxDepth: Byte read GetMaxDepth write SetMaxDepth;

    property NodeDepth: Byte read GetNodeDepth write SetNodeDepth;

    property InnerHashSize: Byte read GetInnerHashSize write SetInnerHashSize;

    property LeafSize: UInt32 read GetLeafSize write SetLeafSize;

    property NodeOffset: UInt64 read GetNodeOffset write SetNodeOffset;

    property IsLastNode: Boolean read GetIsLastNode write SetIsLastNode;

  end;

implementation

{ TBlake2STreeConfig }

procedure TBlake2STreeConfig.ValidateFanOut(AFanOut: Byte);
begin
  if not(AFanOut in [0 .. 255]) then
  begin
    raise EArgumentInvalidHashLibException.CreateRes(@SInvalidFanOutParameter);
  end;
end;

procedure TBlake2STreeConfig.ValidateInnerHashSize(AInnerHashSize: Byte);
begin
  if not(AInnerHashSize in [0 .. 32]) then
  begin
    raise EArgumentInvalidHashLibException.CreateRes
      (@SInvalidInnerHashSizeParameter);
  end;
end;

procedure TBlake2STreeConfig.ValidateMaxDepth(AMaxDepth: Byte);
begin
  if not(AMaxDepth in [1 .. 255]) then
  begin
    raise EArgumentInvalidHashLibException.CreateRes
      (@SInvalidMaxDepthParameter);
  end;
end;

procedure TBlake2STreeConfig.ValidateNodeDepth(ANodeDepth: Byte);
begin
  if not(ANodeDepth in [0 .. 255]) then
  begin
    raise EArgumentInvalidHashLibException.CreateRes
      (@SInvalidNodeDepthParameter);
  end;
end;

procedure TBlake2STreeConfig.ValidateNodeOffset(ANodeOffset: UInt64);
begin
  if ANodeOffset > UInt64((UInt64(1) shl 48) - 1) then
  begin
    raise EArgumentInvalidHashLibException.CreateRes
      (@SInvalidNodeOffsetParameter);
  end;
end;

function TBlake2STreeConfig.GetFanOut: Byte;
begin
  result := FFanOut;
end;

function TBlake2STreeConfig.GetInnerHashSize: Byte;
begin
  result := FInnerHashSize;
end;

function TBlake2STreeConfig.GetIsLastNode: Boolean;
begin
  result := FIsLastNode;
end;

function TBlake2STreeConfig.GetLeafSize: UInt32;
begin
  result := FLeafSize;
end;

function TBlake2STreeConfig.GetMaxDepth: Byte;
begin
  result := FMaxDepth;
end;

function TBlake2STreeConfig.GetNodeDepth: Byte;
begin
  result := FNodeDepth;
end;

function TBlake2STreeConfig.GetNodeOffset: UInt64;
begin
  result := FNodeOffset;
end;

procedure TBlake2STreeConfig.SetFanOut(AValue: Byte);
begin
  ValidateFanOut(AValue);
  FFanOut := AValue;
end;

procedure TBlake2STreeConfig.SetInnerHashSize(AValue: Byte);
begin
  ValidateInnerHashSize(AValue);
  FInnerHashSize := AValue;
end;

procedure TBlake2STreeConfig.SetIsLastNode(AValue: Boolean);
begin
  FIsLastNode := AValue;
end;

procedure TBlake2STreeConfig.SetLeafSize(AValue: UInt32);
begin
  FLeafSize := AValue;
end;

procedure TBlake2STreeConfig.SetMaxDepth(AValue: Byte);
begin
  ValidateMaxDepth(AValue);
  FMaxDepth := AValue;
end;

procedure TBlake2STreeConfig.SetNodeDepth(AValue: Byte);
begin
  ValidateNodeDepth(AValue);
  FNodeDepth := AValue;
end;

procedure TBlake2STreeConfig.SetNodeOffset(AValue: UInt64);
begin
  ValidateNodeOffset(AValue);
  FNodeOffset := AValue;
end;

constructor TBlake2STreeConfig.Create;
begin
  Inherited Create();
  ValidateInnerHashSize(32);
  FInnerHashSize := 32;
end;

end.
