/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React from 'react';
import {
  Button,
  SafeAreaView,
  ScrollView,
  StatusBar,
  Text,
  useColorScheme,
  View,
} from 'react-native';

import {Colors, Header} from 'react-native/Libraries/NewAppScreen';
import NativeCalculator from './js/NativeCalculator';

function App(): JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';
  const [result, setResult] = React.useState<number | undefined>(undefined);

  const compute = async () => {
    const newRes = await NativeCalculator?.add(5, 2);
    setResult(newRes);
  };

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar
        barStyle={isDarkMode ? 'light-content' : 'dark-content'}
        backgroundColor={backgroundStyle.backgroundColor}
      />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={backgroundStyle}>
        <Header />
      </ScrollView>
      <View>
        <Text>5 + 2 = {result ? `${result}` : '???'}</Text>
        <Button title="Compute" onPress={compute} />
      </View>
    </SafeAreaView>
  );
}
export default App;
