/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @flow strict-local
 * @format
 */

import * as React from 'react';
import {useRef, useState} from 'react';
import {View, Button} from 'react-native';
import RNTMyNativeView, {
  Commands as RNTMyNativeViewCommands,
} from './MyNativeViewNativeComponent';
import type {MyNativeViewType} from './MyNativeViewNativeComponent';

const colors = [
  '#0000FF',
  '#FF0000',
  '#00FF00',
  '#003300',
  '#330000',
  '#000033',
];

// This is an example component that migrates to use the new architecture.
export default function MyNativeView(props: {}): React.Node {
  const ref = useRef<React.ElementRef<MyNativeViewType> | null>(null);
  const [opacity, setOpacity] = useState(1.0);

  // [macOS Use this "hack" to only render this example if Fabric is enabled and allow CI to pass
  // Fabric Detection
  const [isFabric, setIsFabric] = useState<boolean>(false);
  const callbackRef = (ref: React.ElementRef<typeof View> | null): void => {
    if (ref == null) {
      return;
    }
    // Avoid dot notation because at Meta, private properties are obfuscated.
    // $FlowFixMe[prop-missing]
    const _internalInstanceHandler = ref['_internalInstanceHandle']; // eslint-disable-line dot-notation
    setIsFabric(Boolean(_internalInstanceHandler?.stateNode?.canonical));
  };

  if (!isFabric) {
    return <View ref={callbackRef} />;
  }
  // macOS]

  return (
    <View style={{flex: 1}}>
      <RNTMyNativeView ref={ref} style={{flex: 1}} opacity={opacity} />
      <Button
        title="Change Background"
        onPress={() => {
          if (ref.current) {
            RNTMyNativeViewCommands.callNativeMethodToChangeBackgroundColor(
              ref.current,
              colors[Math.floor(Math.random() * 5)],
            );
          }
        }}
      />
      <Button
        title="Set Opacity"
        onPress={() => {
          setOpacity(Math.random());
        }}
      />
      <Button
        title="Console.log Measure"
        onPress={() => {
          ref.current?.measure((x, y, width, height) => {
            console.log(x, y, width, height);
          });
        }}
      />
    </View>
  );
}
