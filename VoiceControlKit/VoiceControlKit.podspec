Pod::Spec.new do |spec|
  spec.name         = "VoiceControlKit"
  spec.version      = "1.0"
  spec.summary      = "iOS framework that enables detecting and handling voice commands using microphone."
  spec.description  = "iOS framework that enables detecting and handling voice commands using microphone. Build using Swift, and supports online and offline speech recognition."
  spec.homepage     = "https://github.com/ahmedabdelkarim/VoiceControlKit"
  spec.license      = "MIT"
  
  spec.author             = { "Ahmed Abdelkarim" => "ahmed.karim.tantawy@live.com" }
  spec.social_media_url   = "https://www.linkedin.com/in/ahmedabdelkarim"

  spec.platform     = :ios, "14.3"
  spec.swift_versions = "5.0"

  spec.source       = { :git => "https://github.com/ahmedabdelkarim/VoiceControlKit.git", :tag => spec.version.to_s }

  spec.source_files  = "VoiceControlKit/**/*.{swift}"
 
end
