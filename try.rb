




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


def finder_by_type(s)
  # for example, find_by_type('UIATableCell')
  l10n = Java::OrgUiautomationIosUIAModelsPredicate::L10NStrategy.none
  mat = Java::OrgUiautomationIosUIAModelsPredicate::MatchingStrategy.exact
  Java::OrgUiautomationIosUIAModelsPredicate::TypeCriteria.new(s, l10n, mat)
end
module IOS
  module O
    include_package 'org.uiautomation.ios.UIAModels.predicate'
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
      # TODO
    rescue org.uiautomation.ios.exceptions.NoSuchElementException
      []
    end
    
    # arguably this should be done via method_missing magic
    def tap
      self.raw_element.tap
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
        if opts[:type].kind_of? String
          l10n = O::L10NStrategy.none
          mat = O::MatchingStrategy.exact
          rc = O::TypeCriteria.new(opts[:type], l10n, mat)
          #l10n = Java::OrgUiautomationIosUIAModelsPredicate::L10NStrategy.none
          #l10n = Java::OrgUiautomationIosUIAModelsPredicate::L10NStrategy.none
          #mat = Java::OrgUiautomationIosUIAModelsPredicate::MatchingStrategy.exact
          # rc = Java::OrgUiautomationIosUIAModelsPredicate::TypeCriteria.new(s, l10n, mat)
          crit = Criteria.new(:raw_criteria => rc)
          crits << crit
        end
        
        # TODO: more kinds of picking
        
        if crits.size < 1
          self.raw_criteria = Java::OrgUiautomationIosUIAModelsPredicate::EmptyCriteria.new
        elsif crits.size == 1
          self.raw_criteria = crits[0].raw_criteria
        else
          # TODO: `and` them
        end
      end
    end
    def or(*args)
      margs = ([self] + args).map { |x| x.raw_criteria }
      Criteria.new(:raw_criteria =>
                   Java::OrgUiautomationIosUIAModelsPredicate::OrCritera.new(margs))
    end
    def and(*args)
      margs = ([self] + args).map { |x| x.raw_criteria }
      Criteria.new(:raw_criteria => 
                   Java::OrgUiautomationIosUIAModelsPredicate::AndCritera.new(margs))
    end
    def not(*args)
      Criteria.new(:raw_criteria => 
                   Java::OrgUiautomationIosUIAModelsPredicate::AndCritera.new(self.raw_criteria))
    end
  end
end

# O::TypeCriteria.new('UIATableCell', O::L10NStrategy.none, O::MatchingStrategy.exact)
# IOS::UIAModels::Predicates::TypeCriteria.new('UIATableCell', 





driver = IOS::Driver.new
somecell = driver.find_element(:type => 'UIATableCell')
somecell.tap
driver.take_screenshot('step2-ruby.png')
driver.quit
