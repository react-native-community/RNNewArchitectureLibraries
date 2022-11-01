#include <react/renderer/core/ConcreteComponentDescriptor.h>
#include "RTNImageComponentCustomShadowNode.h"

namespace facebook {
namespace react {

/*
 * Descriptor for <RTNImageComponentCustomComponentDescriptor>
 * component.
 */
class RTNImageComponentCustomComponentDescriptor final
    : public ConcreteComponentDescriptor<
          RTNImageComponentCustomShadowNode> {
 public:
  RTNImageComponentCustomComponentDescriptor(
      ComponentDescriptorParameters const &parameters)
      : ConcreteComponentDescriptor(parameters),
        imageManager_(std::make_shared<ImageManager>(contextContainer_)) {}

  void adopt(ShadowNode::Unshared const &shadowNode) const override {
    ConcreteComponentDescriptor::adopt(shadowNode);

    auto compShadowNode =
        std::static_pointer_cast<RTNImageComponentCustomShadowNode>(
            shadowNode);

    // `RTNImageComponentCustomShadowNode` uses `ImageManager` to
    // initiate image loading and communicate the loading state
    // and results to mounting layer.
    compShadowNode->setImageManager(imageManager_);
  }

 private:
  const SharedImageManager imageManager_;
};

} // namespace react
} // namespace facebook
