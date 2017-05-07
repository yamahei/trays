# -*- coding: utf-8 -*-
require './1.enviroment.rb'

class Assort
  def initialize
    @env = Enviroment.new
  end

  def do_layout
    trays = []
    orders = @env.get_order
    #全アイテム配置終わるまで繰り返し
    while !orders.empty? do
      p orders
      #先頭（大きい）のアイテムの高さに応じてトレイを選択
      tray = @env.get_tray_by_item(orders[0])
      #トレイに収納
      tray.storage(orders, @env.master)
      #トレイ終わり
      trays << tray
      #出力
      puts_layout(tray)
    end
  end

  def puts_layout(tray)
    puts "Tray: #{tray.name}(#{tray.size})"
    puts tray.rect.inspect
    puts ""
  end
end

a = Assort.new
a.do_layout
