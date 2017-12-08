Pod::Spec.new do |s|

  s.name         = "LPMAutoStatistics"
  s.version      = "0.0.1"
  s.summary      = "LPMAutoStatistics."
  s.description  = <<-DESC
                    LPMAutoStatistics 是一个自动打点的系统，配置好了后 可以直接由产品经理完成埋点 
                   DESC

  s.homepage     = "https://github.com/JaylonPan/LPMAutoStatistics"
  s.source       = {:git => "https://github.com/JaylonPan/LPMAutoStatistics.git", :tag => "#{s.version}"}
  s.license      = { :type => 'MIT', :text => <<-LICENSE
                      Copyright 2017
                      JaylonPan
                    LICENSE
                    }
  s.author       = { "Jaylon" => "269003942@qq.com" }
  s.platform     = :ios, "8.0"
  s.source_files  = "LPMAutoStatistics.{h,m}"
  s.header_dir = 'LPMAutoStatistics'
  
  s.dependency 'LPMHookUtils'
end