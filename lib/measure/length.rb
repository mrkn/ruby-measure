# = Definitions of the length dimension units
#
# Author::    Kenta Murata
# Copyright:: Copyright (C) 2008 Kenta Murata
# License::   LGPL version 3.0

require 'measure'

Measure.class_eval do
  {
    :m    => :meter,
    :km   => :kilo_meter,
    :cm   => :centi_meter,
    :mm   => :milli_meter,
    :um   => :micro_meter,
    :nm   => :nano_meter,
    :in   => :inch,
    :ft   => :feet,
    :yd   => :yard,
  }.each do |short, long|
    def_unit long, :length
    def_alias short, long
  end

  def_conversion :m, :cm => 100, :mm => 1000, :um => 1000000, :nm => 1000000000
  def_conversion :km, :m => 1000
  def_conversion :cm, :mm => 10
  def_conversion :mm, :um => 1000
  def_conversion :um, :nm => 1000
  def_conversion :in, :m => 0.254, :cm => 2.54, :mm => 25.4
  def_conversion :ft, :in => 12
  def_conversion :yd, :in => 36, :ft => 3

  # for DTP

  def_unit :point, :length
  def_alias :pt, :point
  def_alias :didot_point, :point
  def_alias :dp, :didot_point

  def_unit :big_point, :length
  def_alias :bp, :big_point

  def_unit :pica, :length
  def_alias :pc, :pica

  def_conversion :in, :pt => 72.27, :bp => 72.0
  def_conversion :pc, :pt => 12
end
