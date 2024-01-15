import { StatusBar } from 'expo-status-bar';
import React, { useCallback, useEffect, useState }  from 'react';
import MindboxSdk, { LogLevel } from "mindbox-sdk";
import { Alert, StyleSheet, Text, View } from 'react-native';

const App = () => {
  const [uuid, setUuid] = useState('');
  const [token, setToken] = useState('');

  const callback = useCallback((pushUrl, pushPayload) => {
    setTimeout(() => {
      Alert.alert("Push Notification Data", `${pushUrl}\n${pushPayload}`);
    }, 600);

    console.log("onPushClickReceived");
  }, []);

  const appInitializationCallback = useCallback(async () => {
      const configuration = {
        domain: 'api.mindbox.ru',
        endpointId: 'pushok-rn-ios-sandbox',
        subscribeCustomerIfCreated: true,
        shouldCreateCustomer: true,
      };
      MindboxSdk.setLogLevel(LogLevel.DEBUG);
      await MindboxSdk.initialize(configuration);

      MindboxSdk.onPushClickReceived(callback);

      MindboxSdk.getDeviceUUID((uuid) => { 
        console.log(`getDeviceUUID ${uuid}`);
        setUuid(uuid)
      });

      MindboxSdk.getToken((token) => { 
        console.log(`getToken ${token}`);
        setToken(token)
      });

      return () => {
        MindboxSdk.removeOnPushClickReceived();
      };

  }, []).call();

  return (
    <View style={styles.container}>
      <Text>Mindbox</Text>
      <StatusBar style="auto" />
      <Text>UUID {uuid}</Text>
      <Text>Token {token}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default App;