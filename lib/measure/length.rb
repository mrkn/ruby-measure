# = Definitions of the length dimension units
#
# Author::    Kenta Murata
# Copyright:: Copyright (C) 2008 Kenta Murata
# License::   LGPL version 3.0

require 'measure'

Measure.define_unit :meter, :length
Measure.define_alias :m, :meter

Measure.define_unit :kilo_meter, :length
Measure.define_alias :km, :kilo_meter

Measure.define_unit :centi_meter, :length
Measure.define_alias :cm, :centi_meter

Measure.define_unit :milli_meter, :length
Measure.define_alias :mm, :milli_meter

Measure.define_unit :micro_meter, :length
Measure.define_alias :um, :micro_meter

Measure.define_unit :nano_meter, :length
Measure.define_alias :nm, :nano_meter

Measure.define_unit :inch, :length
Measure.define_alias :in, :inch

Measure.define_unit :feet, :length
Measure.define_alias :ft, :feet

Measure.define_unit :yard, :length
Measure.define_alias :yd, :yard

Measure.define_conversion :m, :cm => 100, :mm => 1000, :um => 1000000, :nm => 1000000000
Measure.define_conversion :km, :m => 1000
Measure.define_conversion :cm, :mm => 10
Measure.define_conversion :mm, :um => 1000
Measure.define_conversion :um, :nm => 1000
Measure.define_conversion :in, :m => 0.254, :cm => 2.54, :mm => 25.4
Measure.define_conversion :ft, :in => 12
Measure.define_conversion :yd, :in => 36, :ft => 3

# for DTP

Measure.define_unit :point, :length
Measure.define_alias :pt, :point
Measure.define_alias :didot_point, :point
Measure.define_alias :dp, :didot_point

Measure.define_unit :big_point, :length
Measure.define_alias :bp, :big_point

Measure.define_unit :pica, :length
Measure.define_alias :pc, :pica

Measure.define_conversion :in, :pt => 72.27, :bp => 72.0
Measure.define_conversion :pc, :pt => 12
