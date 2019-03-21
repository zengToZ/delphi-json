unit Testdjson;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, Variants, SysUtils, Classes, Dialogs, djson, windows, dateutils,
  generics.collections;

type
  // Test methods for class TJSON

  TestTdJSON = class(TTestCase)
  strict private
    function loadFile(const AFilename: string): string;
  public                                               
  published
    procedure TestUser;
    procedure TestUserList;
    procedure TestListInListInList;
    procedure TestEmptyList;
    procedure TestMovie;
    procedure TestUnEscape;
    procedure TestEmptyDict;
  end;

var
  fmt: TFormatSettings;

implementation

uses
  madexcept;

function TestTdJSON.loadFile(const AFilename: string): string;
var
  jsonFile: TextFile;
  text: string;
begin
  result := '';

  AssignFile(jsonFile, AFilename);
  try
    Reset(jsonFile);

    while not Eof(jsonFile) do
    begin
      ReadLn(jsonFile, text);
      result := result+text;
    end;
  finally
    CloseFile(jsonFile);
  end;
end;

procedure TestTdJSON.TestEmptyDict;
begin
  try
  with TdJSON.Parse(loadFile('test7.json')) do
  begin
    try
      check(_['QueryResponse']['Item'][0]['Name'].AsString = 'Advance', 'Name is not Advance');
      check(_['QueryResponse']['Item'][0]['ItemGroupDetail'].Items.Count = 0, 'items.count is not 0');
    finally
      Free;
    end;
  end;
  with TdJSON.Parse(loadFile('test8.json')) do
  begin
    try
      check(_['results'].Items.Count = 0);
    finally
      Free;
    end;
  end;
  except
    handleException;
    raise;
  end;
end;

procedure TestTdJSON.TestEmptyList;
begin
  try
  with TdJSON.Parse(loadFile('test4.json')) do
  begin
    try
      check(IsList = false, 'isList is not false');
      check(_['empty'].IsList = true, 'isList is not true');
      check(assigned(_['empty'].ListItems) = true, 'ListItems is not assigned');
      check(_['empty'].ListItems.count = 0, 'listitems.count is not 0');
    finally
      Free;
    end;
  end;
  with TdJSON.Parse(loadFile('test5.json')) do
  begin
    try
      check(IsList = true, 'isList is not true');
      check(assigned(ListItems) = true, 'listItems is not assigned');
      check(ListItems.count = 0, 'listitems.count is not 0');
    finally
      Free;
    end;
  end;
  except
    handleException;
    raise;
  end;
end;

procedure TestTdJSON.TestListInListInList;
begin
  with TdJSON.Parse(loadFile('test3.json')) do
  begin
    try
      check(_[0].IsList = true);
      check(_[0][0][0].AsString = 'list in a list in a list');
    finally
      Free;
    end;
  end;
end;

procedure TestTdJSON.TestMovie;
begin
  try
  with TdJSON.Parse(loadFile('test6.json')) do
  try
    check(_['page'].AsInteger = 1);
    check(_['results'][0]['id'].AsInteger = 262543);
    check(_['results'][0]['id'].AsString = '262543');
    check(_['results'][0]['original_title'].AsString = 'Automata');
    check(_['results'][0]['popularity'].AsString = '6.6273989934368');
  finally
    free;
  end;
  except
    handleException;
    raise;
  end;
end;

procedure TestTdJSON.TestUnEscape;
begin
  with TdJSON.Parse('{"name": "Kurt \u00e6 bc"}') do
  try
    check(_['name'].AsString = 'Kurt � bc');
  finally
    free;
  end;
  with TdJSON.Parse('{"name": "a \b b"}') do
  try
    check(_['name'].AsString = 'a '+#8+' b');
  finally
    free;
  end;
  with TdJSON.Parse('{"name": "a \n b"}') do
  try
    check(_['name'].AsString = 'a '+#10+' b');
  finally
    free;
  end;
  with TdJSON.Parse('{"name": "a \r b"}') do
  try
    check(_['name'].AsString = 'a '+#13+' b');
  finally
    free;
  end;
  with TdJSON.Parse('{"name": "a \t b"}') do
  try
    check(_['name'].AsString = 'a '+#9+' b');
  finally
    free;
  end;
  with TdJSON.Parse('{"name": "a \f b"}') do
  try
    check(_['name'].AsString = 'a '+#12+' b');
  finally
    free;
  end;

  with TdJSON.Parse('{"name": "\\"}') do
  try
    check(_['name'].AsString = '\');
  finally
    free;
  end;
end;

procedure TestTdJSON.TestUser;
var
  photo, item: TdJSON;
  i: integer;
  d: double;
begin
  try
  with TdJSON.Parse(loadFile('test1.json')) do
  begin
    try
      Check(_['username'].AsString = 'thomas', _['username'].AsString + ' is not thomas');
      for i in [1,2] do
      begin
        photo := _['photos'][i-1];
        check(photo['title'].AsString = format('Photo %d', [i]), 'title is not '+format('Photo %d', [i]));
        check(assigned(photo['urls']));
        check(photo['urls']['small'].AsString = format('http://example.com/photo%d_small.jpg', [i]), 'url is not '+format('http://example.com/photo%d_small.jpg', [i]));
        check(photo['urls']['large'].AsString = format('http://example.com/photo%d_large.jpg', [i]), 'url is not '+format('http://example.com/photo%d_large.jpg', [i]));
      end;

      for i in [1,2,3] do
      begin
        item := _['int_list'][i-1];
        check(item.AsInteger = i, format('item value is not %d', [i]));
      end;

      for i in [1,2,3] do
      begin
        item := _['str_list'][i-1];
        check(item.AsString = inttostr(i), format('item value is not %d', [i]));
      end;

      check(_['escape_text'].AsString = 'Some "test" \\ \u00e6=�', format('%s is not Some "test" \\ \u00e6=�', [_['escape_text'].AsString]));
      check(_['escape_path'].AsString = 'C:\test\test.txt', format('%s is not C:\test\test.txt', [_['escape_path'].AsString]));

      check(_['nullvalue'].AsString = '', 'nullvalue is not empty');
      check(_['nullvalue'].IsNull, 'nullvalue value is not null');

      check(_['null_list'].ListItems.Count = 1, format('null_list count is not 1: %d', [_['null_list'].ListItems.Count]));
      check(_['emptyList'].ListItems.Count = 0, format('emptyList is not empty: %d', [_['null_list'].ListItems.Count]));
      check(_['emptyStringList'].ListItems.Count = 1, format('emptyStringList count is not 1: %d', [_['emptyStringList'].ListItems.Count]));

      check(_['list_in_list'][0][0].AsInteger = 1, '_[''list_in_list''][0][0] is not 1');
      check(_['list_in_list'][0][1].AsInteger = 2, '_[''list_in_list''][0][1] is not 2');
      check(_['list_in_list'][1][0].AsInteger = 3, '_[''list_in_list''][1][0] is not 3');
      check(_['list_in_list'][1][1].AsInteger = 4, '_[''list_in_list''][1][1] is not 4');

      check(_['bool_true'].AsBoolean, 'bool_true is not true');
      check(not _['bool_false'].AsBoolean, 'bool_false is not false');
      DebugStr(_['double'].AsDouble);

      d := 1.337;
      check(_['double'].AsDouble = d, 'double is not 1.337');

    finally
      Free;
    end;
  end;
  except
    handleException;
    raise;
  end;
end;

procedure TestTdJSON.TestUserList();
var
  users: TdJSON;
  user: TdJSON;
  i: integer;
begin
  try
  users := TdJSON.Parse(loadFile('test2.json'));
  try
    check(users.ListItems.Count = 3, format('%d is not 3', [users.ListItems.Count]));
    for i in [0,1,2] do
    begin
      user := users[i];
      case i of
        0: check(user['username'].AsString = 'thomas', user['username'].AsString+' is not thomas');
        1: check(user['name'].AsString = 'Kurt', user['name'].AsString+' is not kurt');
        2: check(user['username'].AsString = 'bent', user['username'].AsString+' is not bent');
      end;
    end;
  finally
    users.free;
  end;
  except
    handleException;
    raise;
  end;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTdJSON.Suite);
end.

