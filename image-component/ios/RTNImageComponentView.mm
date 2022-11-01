#import "RTNImageComponentView.h"

#import <react/renderer/components/RTNImageViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/RTNImageViewSpec/EventEmitters.h>
#import <react/renderer/components/RTNImageViewSpec/Props.h>
#import <react/renderer/components/RTNImageViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface RTNImageComponentView () <RCTRTNImageComponentViewProtocol>
@end

@implementation RTNImageComponentView {
  UIView *_view;
  UIImageView *_imageView;
  UIImage *_image;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<RTNImageComponentComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const RTNImageComponentProps>();
    _props = defaultProps;

    _view = [[UIView alloc] init];
    _view.backgroundColor = [UIColor redColor];

    _imageView = [[UIImageView alloc] init];
    [_view addSubview:_imageView];

    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
      [_imageView.topAnchor constraintEqualToAnchor:_view.topAnchor constant:10],
      [_imageView.leftAnchor constraintEqualToAnchor:_view.leftAnchor constant:10],
      [_imageView.bottomAnchor constraintEqualToAnchor:_view.bottomAnchor constant:-10],
      [_imageView.rightAnchor constraintEqualToAnchor:_view.rightAnchor constant:-10],
    ]];
    _imageView.image = _image;

    self.contentView = _view;
  }

  return self;
}

- (void)prepareForRecycle
{
  [super prepareForRecycle];
  _image = nil;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  [super updateProps:props oldProps:oldProps];
}

- (void)updateState:(facebook::react::State::Shared const &)state
           oldState:(facebook::react::State::Shared const &)oldState
{
  auto _state = std::static_pointer_cast<RTNImageComponentShadowNode::ConcreteState const>(state);
  auto _oldState = std::static_pointer_cast<RTNImageComponentShadowNode::ConcreteState const>(oldState);
}

@end

Class<RCTComponentViewProtocol> RTNImageComponentCls(void)
{
  return RTNImageComponentView.class;
}
