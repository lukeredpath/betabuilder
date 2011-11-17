module BetaBuilder
  class BuildOutputParser

    def initialize(output)
      @output = output
    end

    def build_output_dir
      # yes, this is truly horrible, but unless somebody else can find a better way...
      found = @output.split("\n").grep(/^Validate(.*)\/Xcode\/DerivedData\/(.*)-(.*)/).first
      if found && found =~ /Validate [\"]?([^\"|$]*)/
        reference = $1 
      else 
        raise "Cannot parse build_dir from build output."
      end        
      derived_data_directory = reference.split("/Build/Products/").first
      "#{derived_data_directory}/Build/Products/"
    end
  end
end

# quick testing
if __FILE__ == $0   

require 'test/unit'
class BuildOutputTest < Test::Unit::TestCase
  
  def test_parses_output_with_unquoted_build_path
  bop = BetaBuilder::BuildOutputParser.new(<<eos)
Validate /Users/johnsmith/Library/Developer/Xcode/DerivedData/Application-hegpgdbpjylesafhkxnsymrzjavl/Build/Products/Distribution-iphoneos/Application.app
    cd /Users/user/app/ios
    setenv PATH \"/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin:/Developer/usr/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin\"
    setenv PRODUCT_TYPE com.apple.product-type.application
    /Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/Validation /Users/user/Library/Developer/Xcode/DerivedData/Application-hegpgdbpjylesafhkxnsymrzjavl/Build/Products/Distribution-iphoneos/Application.app
eos
    assert_equal "/Users/johnsmith/Library/Developer/Xcode/DerivedData/Application-hegpgdbpjylesafhkxnsymrzjavl/Build/Products/", bop.build_output_dir
  end

  def test_parses_output_with_quoted_build_path
    bop = BetaBuilder::BuildOutputParser.new(<<eos)
Validate \"/Users/john smith/Library/Developer/Xcode/DerivedData/Application-hegpgdbpjylesafhkxnsymrzjavl/Build/Products/Distribution-iphoneos/Application.app\"
    cd /Users/user/app/ios
    setenv PATH \"/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin:/Developer/usr/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin\"
    setenv PRODUCT_TYPE com.apple.product-type.application
    /Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/Validation /Users/user/Library/Developer/Xcode/DerivedData/Application-hegpgdbpjylesafhkxnsymrzjavl/Build/Products/Distribution-iphoneos/Application.app
eos
    assert_equal "/Users/john smith/Library/Developer/Xcode/DerivedData/Application-hegpgdbpjylesafhkxnsymrzjavl/Build/Products/", bop.build_output_dir
  end

end

end
