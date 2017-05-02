# -*- coding: utf-8 -*-
require './1.ready.rb'

class Process
  def initialize
    @env = Enviroment.new
  end

  def do_layout
    trays = []
    orders = @env.get_order
    #全アイテム配置終わるまで繰り返し
    while !orders.empty?{
      #先頭（大きい）のアイテムの高さに応じてトレイを選択
      tray = @env.get_tray_by_item(orders[0])
      #トレイに収納
      tray.storage(orders)
      #トレイ終わり
      trays << tray
    }
    #出力
    puts "* おわり"
  end
end
