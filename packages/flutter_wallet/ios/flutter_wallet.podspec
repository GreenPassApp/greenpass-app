#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_wallet'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin to add pkpass to iOS wallet (Passbook)'
  s.description      = <<-DESC
Flutter plugin to add pkpass to iOS wallet (Passbook)
                       DESC
  s.homepage         = 'https://github.com/vico-aguado/flutter_wallet.git'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Vico Aguado' => 'vico.aguado@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
end

