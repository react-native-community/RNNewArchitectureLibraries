#import "RTNImageComponentView.h"

#import <react/renderer/components/RTNImageViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/RTNImageViewSpec/EventEmitters.h>
#import <react/renderer/components/RTNImageViewSpec/Props.h>
#import <react/renderer/components/RTNImageViewSpec/RCTComponentViewHelpers.h>
#import "ComponentDescriptors.h"

#import <React/RCTImageResponseDelegate.h>
#import <React/RCTImageResponseObserverProxy.h>
#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface RTNImageComponentView () <RCTRTNImageComponentViewProtocol, RCTImageResponseDelegate>
@end

@implementation RTNImageComponentView {
  UIView *_view;
  UIImageView *_imageView;
  UIImage *_image;
  ImageResponseObserverCoordinator const *_imageCoordinator;
  RCTImageResponseObserverProxy _imageResponseObserverProxy;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<RTNImageComponentCustomComponentDescriptor>();
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

    _imageResponseObserverProxy = RCTImageResponseObserverProxy(self);

    self.contentView = _view;
  }

  return self;
}

- (void)prepareForRecycle
{
  [super prepareForRecycle];
  self.imageCoordinator = nullptr;
  _image = nil;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  [super updateProps:props oldProps:oldProps];
}

- (void)updateState:(facebook::react::State::Shared const &)state
           oldState:(facebook::react::State::Shared const &)oldState
{
  auto _state = std::static_pointer_cast<RTNImageComponentCustomShadowNode::ConcreteState const>(state);
  auto _oldState = std::static_pointer_cast<RTNImageComponentCustomShadowNode::ConcreteState const>(oldState);

  auto data = _state->getData();

  bool havePreviousData = _oldState != nullptr;

  auto getCoordinator = [](ImageRequest const *request) -> ImageResponseObserverCoordinator const * {
    if (request) {
      return &request->getObserverCoordinator();
    } else {
      return nullptr;
    }
  };

  if (!havePreviousData || data.getImageSource() != _oldState->getData().getImageSource()) {
    self.imageCoordinator = getCoordinator(&data.getImageRequest());
  }
}
#pragma mark - ImageCoordination

- (void)setImageCoordinator:(const ImageResponseObserverCoordinator *)coordinator
{
  if (_imageCoordinator) {
    _imageCoordinator->removeObserver(_imageResponseObserverProxy);
  }
  _imageCoordinator = coordinator;
  if (_imageCoordinator) {
    _imageCoordinator->addObserver(_imageResponseObserverProxy);
  }
}

- (void)setImage:(UIImage *)image
{
  if ([image isEqual:_image]) {
    return;
  }

  _imageView.image = image;
}

#pragma mark - RCTImageResponseDelegate

- (void)didReceiveImage:(UIImage *)image metadata:(id)metadata fromObserver:(void const *)observer
{
  if (observer == &_imageResponseObserverProxy) {
    self.image = image;
  }
}

- (void)didReceiveProgress:(float)progress fromObserver:(void const *)observer
{
}

- (void)didReceiveFailureFromObserver:(void const *)observer
{
}

@end

Class<RCTComponentViewProtocol> RTNImageComponentCls(void)
{
  return RTNImageComponentView.class;
}
