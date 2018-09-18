# -*- coding: utf-8 -*-
require 'rubygems'
require 'dbi'
require 'date'

class BookInfo
    # BookInfoクラスのインスタンスを初期化する
    def initalize(title,author,page,publish_date)
        @title = title
        @author = author
        @page = page
        @publish_date = publish_date
    end

    # 属性に対するアクセサを提供する
    attr_accessor :title, :author, :page, :publish_date

    # BookInfoクラスのインスタンスの文字列表現を返す
    def to_s
        "#{@title},#{@author},#{@page},#{@publish_date}"
    end

    # 蔵書データに書式を付けて出力する操作を追加する
    # 項目の区切り文字を引数に指定する
    # 引数を省略した場合は改行を区切り文字にする
    def toFormattedString( sep = "\n")
        "書式名: #{@title}#{sep}著者名: #{@author}#{seq}ページ数: #{@page}ページ#{sep}発刊日: #{@publish_date}#{sep}"
    end
end

# BookInfoManagerクラスを定義する
class BookInfoManager
    def initialize(sqlite_name)
        # SQLiteデータベースファイルに接続
        @db_name = sqlite_name
        @dbh = DBI.connect("DBI:SQLITE3:#{@db_name}")
    end

    # 蔵書データを初期化する
    def initBookInfos
        puts "\n0. 蔵書データの初期化"
        print "初期化しますか？([Y/y]なら削除を実行します):"
        # 読み込んだ値を大文字に揃える
        yasno = gets.chomp.upcase
        if /^Y$/ =~ yesno
            # Yが1文字のときだけ、初期化する
            # もしすでにこのデータベースにテーブル'bookinfos'があれば削除する
            @dbh.do("drop table if exists bookinfos")
            # 新しく'bookinfos'テーブルを作成する
            @dbh.do("create table bookinfos
                id              varchar(50)  not null,
                title          varchar(100) not null,
                author          varchar(100) not null,
                page            int          not null,
                publish_date    datetime     not null,
                primary         key(id));")
            puts "\nデータベースを初期化しました。"
            end
        end

        # 蔵書データを登録する
        def addBookInfo
            puts "\n1.蔵書データの登録"
            print "蔵書データを登録します。"

        # 蔵書データ1件分のインスタンスを作成する
        book_info = BookInfo.new("","", 0, Date.new)
        # 登録するデータを項目ごとに入力する
        print "\n"
        print "キー : "
        key = gets.chomp
        print "書式名: "
        book_info.title = gets.chomp
        print "著者名: "
        book_info.author = gets.chomp
        print "ページ数: "
        book_info.page = gets.chomp.to_i
        print "発刊年: "
        year = gets.chomp.to_i
        print "発刊月: "
        month = gets.chomp.to_i
        print "発刊日: "
        day = gets.chomp.to_i
        book_info.publish_date = Date.new(year,month,day)

        # 作成した蔵書データを1件分をデータベースに登録する
        @dbh.do("insert into bookinfos values (
            \'#{key}\',
            \'#{book_info.title}\',
            \'#{book_info.author}\',
            \'#{book_info.page}\',
            \'#{book_info.publish_date}\');")
            puts "\n登録しました"
        end

        # 蔵書データの一覧を表示する
        def listAllBookInfos
            # テーブル上の項目名を日本語に帰るハッシュテーブル
            item_name = {'id' => "キー", 'title' => "書式名", "author" => "著者名", 'page' => "ページ数", 'publish_date' => "発刊日" }

            puts "\n2.蔵書データの表示"
            print "蔵書データを表示します。"

            puts "\n----------------------"

            # テーブルからデータを読み込んで表示する
            sth = @dbh.execute("select * from bookinfos")

            # select文の実行結果を1件ずつrowに取り出し、繰り返し処理をする
            counts = 0
            sth.each do |row|
                row.each_widh_name do |val,name|
                    puts "#{item_name[name]}: #{val.to_s}"
                end
                puts "------------"
                counts = counts + 1
            end

            # 実行結果を解放する
            sth.finish

            puts "\n#{counts}件を表示しました。"
        end

        # 処理の選択と選択後の処理を繰り返す
        def run
            while true
                # 機能選択画面を表示する
                print "
                    0. 蔵書データベースの初期化
                    1. 蔵書データの登録
                    2. 蔵書データの表示
                    9. 終了
                    番号を選んでください(0,1,2,9)"

                    # 文字の入力を持つ
                    num = gets.chomp
                    case
                    when '0' == num
                        # 蔵書データベースの初期化
                        initBookInfos
                    when '1' == num
                        # 蔵書データの登録
                        addBookInfo
                    when '2' == num
                        # 蔵書データの表示
                        listAllBookInfos
                    when '9' == num
                        # データベースとの接続を終了する
                    @dbh.disconnect
                    # アプリケーションの終了
                    puts "\n終了しました。"
                    break;
                    else
                        # 処理選択待ち画面に戻る
                    end
                end
            end
        end
        # アプリケーションのインスタンスを作成
        book_info_manager = BookInfoManager.new("bookinfo_sqlite.db")

        # BookInfoManagerの処理の選択と選択後の処理を繰り返す
        book_info_manager.run
