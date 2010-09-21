# language: en
Feature: Programmer defines units
  In order to define units
  As a programmer using this library
  I want to define units in a form of DSL

  @wip
  Scenario: No units have been defined yet
    Given a context without any predefined units
    When I pass the block for defining two units, :meter and :inch, to the context_eval method of the context
      """
      unit :meter
      unit :inch
      """
    Then the units :meter and :inch is defined

