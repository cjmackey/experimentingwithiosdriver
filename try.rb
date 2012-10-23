




require 'java'

#module IOS
#  include_package 'org.uiautomation.ios'
#  module UIAModels
#    include_package 'org.uiautomation.ios.UIAModels'
#    module Predicates
#      include_package 'org.uiautomation.ios.UIAModels.predicate'
#    end
#  end
#end
#
#puts IOS::IOSCapabilities.inspect
#puts IOS::UIAModels::UIATableCell.inspect
#puts IOS::UIAModels::Predicates::TypeCriteria.inspect


module IOS
  module Predicate
    include_package 'org.uiautomation.ios.UIAModels.predicate'
  end
  
  class Element
    attr_accessor :raw_element
    def initialize(opts={})
      self.raw_element = opts[:raw_element]
    end
    def find_element(opts={})
      crit = Criteria.new(opts)
      Element.new(:raw_element => self.raw_element.findElement(crit.raw_criteria))
    rescue org.uiautomation.ios.exceptions.NoSuchElementException
      nil
    end
    def find_elements(opts={})
      crit = Criteria.new(opts)
      self.raw_element.findElements(crit.raw_criteria).to_a.map do |re|
        Element.new(:raw_element => re)
      end
    rescue org.uiautomation.ios.exceptions.NoSuchElementException
      []
    end
    
    # arguably this should be done via method_missing magic
    def tap
      self.raw_element.tap
    end
  end
  
  class Driver < Element
    attr_accessor :raw_driver, :raw_target, :raw_app
    def initialize
      cap = Java::OrgUiautomationIos::IOSCapabilities.iphone(ENV['APP_NAME'],
                                                             ENV['APP_VERSION'])
      cap.setLanguage('en')
      self.raw_driver = Java::OrgUiautomationIosClientUiamodelsImpl::RemoteUIADriver.new("http://localhost:4444/wd/hub", cap)
      self.raw_target = raw_driver.getLocalTarget
      self.raw_app = raw_target.getFrontMostApp
      self.raw_element = raw_app.getMainWindow
    end
    
    def take_screenshot(fname)
      raw_target.takeScreenshot(fname)
    end
    
    def quit
      self.raw_driver.quit
    end
  end
  
  class Criteria
    attr_accessor :raw_criteria
    def initialize(opts={})
      if opts.kind_of? Criteria
        self.raw_criteria = opts.raw_criteria
        return
      end
      
      if opts[:raw_criteria]
        self.raw_criteria = opts[:raw_criteria]
      else
        crits = []
        
        # TODO: make the regexp.source also do things with options (like case insensitivity)
        
        if opts[:type].kind_of? String
          l10n = Predicate::L10NStrategy.none
          mat = Predicate::MatchingStrategy.exact
          crits << Predicate::TypeCriteria.new(opts[:type], l10n, mat)
        elsif opts[:type].kind_of? Regexp
          l10n = Predicate::L10NStrategy.none
          mat = Predicate::MatchingStrategy.regex
          crits << Predicate::TypeCriteria.new(opts[:type].source, l10n, mat)
        end
        
        if opts[:label].kind_of? String
          crits << Predicate::LabelCriteria.new(opts[:label])
        elsif opts[:label].kind_of? Regexp
          crits << Predicate::LabelCriteria.new(opts[:label].source,
                                                Predicate::MatchingStrategy.regex)
        end
        
        if opts[:name].kind_of? String
          crits << Predicate::NameCriteria.new(opts[:name])
        elsif opts[:name].kind_of? String
          crits << Predicate::NameCriteria.new(opts[:name].source,
                                               Predicate::MatchingStrategy.regex)
        end
        
        # TODO: more kinds of picking -- value, properties
        
        if crits.size < 1
          self.raw_criteria = Predicate::EmptyCriteria.new
        elsif crits.size == 1
          self.raw_criteria = crits[0]
        else
          self.raw_criteria = Predicate::AndCriteria.new(*crits)
        end
      end
    end
    def or(*args)
      margs = ([self] + args).map { |x| x.raw_criteria }
      Criteria.new(:raw_criteria => Predicate::OrCritera.new(*margs))
    end
    def and(*args)
      margs = ([self] + args).map { |x| x.raw_criteria }
      Criteria.new(:raw_criteria => Predicate::AndCritera.new(*margs))
    end
    def not
      Criteria.new(:raw_criteria => Predicate::NotCritera.new(self.raw_criteria))
    end
  end
end




driver = IOS::Driver.new
# Hmm. multiple criteria doesn't seem to work :(
# LocalJumpError: yield called out of block
#      tap at org/jruby/RubyKernel.java:1787
#   (root) at try.rb:146
somecell = driver.find_element( :label => 'Mountain 4' )
                               # :type => 'UIATableCell')#, 
                               #:label => /3/)
somecell.tap
driver.take_screenshot('step2-ruby.png')
driver.quit
