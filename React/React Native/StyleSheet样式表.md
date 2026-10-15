## StyleSheet样式表

```
class LessonStyle extends Component{
  render(){
    return(
      <View style={styles.container}>
        <View style={[styles.top, styles.border]}></View>
        <View style={[styles.bottom, styles.border, {borderColor:"white"}]}></View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  //外层view
  container: {
    marginTop: 25,
    marginLeft: 30,
    backgroundColor: "red",
    width: 300,
    height: 400,
  },
  //上层view
  top: {
    backgroundColor: "green",
    width: 280,
    height: 250,
    margin: 10
  },
  //下层view
  bottom: {
    backgroundColor: "yellow",
    width: 280,
    height: 110,
    margin: 10,
  },
  border:{
    borderWidth: 3,
    borderColor: "black"
  }
});
```

样式名使用驼峰命名法。

每一个样式器之间需要用"`,`"分割。

StyleSheet样式表和HTML5样式的区别：

> - HTML5以`;`结尾，React以`,`结尾。
> - HTML5中key、value都不加引号，React中属于JavaScript对象，key的名字不能出现“`-`”，需要使用驼峰命名法。如果value为字符串，需要加`引号`。
> - HTML5中，value如果是数字需要带单位，React中不需要带单位。
> - 在React中使用选择器样式设置组件样式时，属性名不能使用`class`，需要使用`className`替换。类似的：使用`htmlFor`替换`for`。

### 样式拼接
对一个View使用多种样式，使用数组形式， 样式之间使用"`,`"分割。

> 注意：数组中局后的元素优先级更高。
```
<View style={[styles.top, styles.bottom]}></View>
<View style={[styles.top, styles.bottom, {marginLeft: 20}]}></View>
```
