# Author::    Kenta Murata
# Copyright:: Copyright (C) 2008 Kenta Murata
# License::   LGPL version 3.0

class Measure
  module VERSION
    unless defined? MAJOR
      MAJOR = 0
      MINOR = 2
      TINY  = 0

      STRING = [MAJOR, MINOR, TINY].join('.')

      SUMMARY = "measure version #{STRING}"
    end
  end
end
