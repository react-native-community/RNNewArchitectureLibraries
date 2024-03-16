import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
import { multiply, startListening } from 'react-native-turbo-monorepo';

export default function App() {
  const [result, setResult] = React.useState<number | undefined>();

  React.useEffect(() => {
    const subscribe = startListening((event: any) => {
      console.log('event', event);
    });
    multiply(3, 7).then(setResult);

    return () => {
      subscribe.remove();
    };
  }, []);

  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
