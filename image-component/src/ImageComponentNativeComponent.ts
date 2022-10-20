import type { ViewProps } from 'ViewPropTypes';
import type { HostComponent } from 'react-native';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type {ImageSource} from 'react-native/Libraries/Image';

export interface NativeProps extends ViewProps {
  image?: ImageSource;
  // add other props here
}

export default codegenNativeComponent<NativeProps>(
  'RTNImageComponent'
) as HostComponent<NativeProps>;
