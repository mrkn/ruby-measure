# = Definitions of the weight dimension units
#
# Author::    Kenta Murata
# Copyright:: Copyright (C) 2008 Kenta Murata
# License::   LGPL version 3.0

require 'measure'

class Measure
  {
    :kg    => :kilo_gram,
    :g     => :gram,
    :t     => :ton,
    :mg    => :milli_gram,
    :ug    => :micro_gram,
    :gr    => :grain,
    :oz    => :ounce,
    :oz_av => :ounce,
    :oz_tr => :troy_ounce,
    :toz   => :troy_ounce,
    :lb    => :pound,
    :lb_av => :pound,
    :lb_tr => :troy_pound,
    :kin   => :catty,
    :ryo   => :tael,
  }.each do |a, u|
    def_unit u, :weight unless has_unit? u
    def_alias a, u
  end

  def_conversion :kg, :g => 1_000, :mg => 1_000_000, :ug => 1_000_000_000
  def_conversion :t, :kg => 1_000
  def_conversion :gr, :mg => 64.79891
  def_conversion :oz_av, :gr => 437.5
  def_conversion :oz_tr, :gr => 480, :g => 31.1034768
  def_conversion :lb_av, :gr => 7000, :oz => 16, :kg => 0.45359237
  def_conversion :lb_tr, :gr => 5760, :oz => 12, :kg => 0.3732417216, :lb_av => 144.0/175.0

  def_unit :momme, :weight
  def_conversion :momme, :g => 3.75
  def_conversion :kin, :momme => 160
  def_conversion :kin, :ryo => 16
end
