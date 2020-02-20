object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'H5'#21069#31471#37197#32622#20998#31163#23545#27604#24037#20855'-'#23041#38663#22825#31185#25216
  ClientHeight = 570
  ClientWidth = 883
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    883
    570)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 470
    Width = 79
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #37197#32622#29983#25104#30446#24405' :'
  end
  object mmo_log: TMemo
    Left = 8
    Top = 0
    Width = 881
    Height = 449
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object cbb_cfg: TComboBox
    Left = 8
    Top = 488
    Width = 689
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 1
  end
  object edt_tools_path: TLabeledEdit
    Left = 8
    Top = 536
    Width = 689
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    EditLabel.Width = 47
    EditLabel.Height = 13
    EditLabel.Caption = 'tools'#30446#24405
    TabOrder = 2
  end
  object lbledt_config_latfix: TLabeledEdit
    Left = 736
    Top = 486
    Width = 121
    Height = 21
    Anchors = [akRight, akBottom]
    EditLabel.Width = 52
    EditLabel.Height = 13
    EditLabel.Caption = #37197#32622#21518#32512':'
    TabOrder = 3
  end
  object btn_pull: TButton
    Left = 736
    Top = 539
    Width = 121
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #25289#21462
    TabOrder = 4
    OnClick = btn_pullClick
  end
  object chk_compress_config: TCheckBox
    Left = 736
    Top = 513
    Width = 97
    Height = 17
    Anchors = [akRight, akBottom]
    Caption = #21387#32553#37197#32622
    TabOrder = 5
  end
  object mmo_configtxt: TMemo
    Left = 64
    Top = 81
    Width = 769
    Height = 288
    Lines.Strings = (
      '--require("lfs")'
      '--curPath = lfs.currentdir()'
      ''
      'require"lfs"'
      'function findindir(path, wefind, r_table, intofolder)'
      '    for file in lfs.dir(path) do'
      '        if file ~= "." and file ~= ".." then'
      '            local f = path..'#39'\\'#39'..file'
      '            --print ("\t "..f)'
      '            if string.find(f, wefind) ~= nil then'
      '                --print("\t "..f)'
      '                table.insert(r_table, f)'
      '            end'
      '            local attr = lfs.attributes(f)'
      '            assert(type(attr) == "table")'
      '            if attr.mode == "directory" and intofolder then'
      '                findindir(f, wefind, r_table, intofolder)'
      '            else'
      '                --for name, value in pairs(attr) do'
      '                --    print (name, value)'
      '                --end'
      '            end'
      '        end'
      '    end'
      'end'
      ''
      'local cfgPath = "..\\..\\..\\config\\data\\client_bak"'
      'local oldPath = lfs.currentdir()'
      'lfs.chdir(cfgPath)'
      'luaPath = lfs.currentdir()'
      'lfs.chdir(oldPath)'
      'outputPath = "%cd%"'
      'langFile = "\\language\\lang.config"'
      '--print(langFile)'
      ''
      'local currentFolder = luaPath'
      ''
      'local input_table = {}'
      
        'findindir(currentFolder, "%.config", input_table, true)--Find tx' +
        't File'
      ''
      'luaFiles = {}'
      'for _, v in pairs(input_table) do'
      '    if not string.find(v, "language") then'
      '        local file = io.open(v)'
      '        local readret = file:read("*l")'
      '        file:close()'
      
        '        readret = string.sub(string.match(readret, "^.+={"), 1, ' +
        '-3)'
      '        table.insert(luaFiles, { v, readret })'
      '    end'
      'end')
    TabOrder = 6
    Visible = False
  end
  object btn1: TButton
    Left = 496
    Top = 457
    Width = 75
    Height = 25
    Caption = 'btn1'
    TabOrder = 7
    OnClick = btn1Click
  end
end
