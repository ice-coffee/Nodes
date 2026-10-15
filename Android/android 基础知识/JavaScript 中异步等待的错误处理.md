## JavaScript 中异步等待的错误处理

在异步函数中有许多处理错误的方式，但是就算是经验丰富的开发人员有时也会出错。

假设你有一个异步函数`run()`。这篇文章中，我将介绍三种处理`run()`中错误的方式：try/catch、Golang-style和catch()函数调用。 我也会解释为什么`catch()`是最好的方式。

### try/catch
当刚开始使用async/await时，你可能恨不得用try/catch包裹每个异步步骤。因为如果等待的promise被拒绝JavaScript就会报错。

```
run();

async function run() {
  try {
    await Promise.reject(new Error('Oops!'));
  } catch (error) {
    error.message; // "Oops!"
  }
}
```

try/catch还可以处理同步报错。

```
run();

async function run() {
  const v = null;
  try {
    await Promise.resolve('foo');
    v.thisWillThrow;
  } catch (error) {
    // "TypeError: Cannot read property 'thisWillThrow' of null"
    error.message;
  }
}
```

那是不是把所有的逻辑都放在try/catch里就可以了？并不是。以下代码将导致未处理的错误。`await`关键字将被拒的promise转换为可捕获错误，但是`return`关键字不会。

```
run();

async function run() {
  try {
    // Note that this is a `return`, not `await`
    return Promise.reject(new Error('Oops!'));
  } catch (error) {
    // Will **not** run
  }
}
```

你可以使用`return await`解决上述问题，但是`return await`并不容易让人记住。

另一个缺点是try/catch难以控制它的使用范围。因为那非常容易将所有异步逻辑包装在一个try/catch中。

### JS 中的Golang

另一种常见模式是使用`.then()`将被拒的promise转换为错误对象。然后你就可以像Golang一样使用if (err)来判断了。

```
run();

async function throwAnError() {
  throw new Error('Oops!');
}

async function noError() {
  return 42;
}

async function run() {
  // The `.then(() => null, err => err)` pattern gives you an
  // error if one occurred, or `null` otherwise
  let err = await throwAnError().then(() => null, err => err);
  if (err != null) {
    err.message; // 'Oops'
  }

  err = await noError().then(() => null, err => err);
  err; // null
}
```

如果报错信息和结果你都需要，你可以使用JavaScript，模拟Golang的功能。

```
run();

async function throwAnError() {
  throw new Error('Oops!');
}

async function noError() {
  return 42;
}

async function run() {
  // The `.then(v => [null, v], err => [err, null])` pattern
  // lets you use array destructuring to get both the error and
  // the result
  let [err, res] = await throwAnError().
    then(v => [null, v], err => [err, null]);
  if (err != null) {
    err.message; // 'Oops'
  }

  err = await noError().
    then(v => [null, v], err => [err, null]);
  err; // null
  res; // 42
}
```

下面是一种更简洁的使用方式：

```
const getAnswer = async () => 42;

run();

async function run() {
  try {
    let val = await getAnswer();
  } catch (error) {}

  // ReferenceError: val is not defined
  val;
}
```

golang风格的错误处理并没有消除return的影响。它只会增加错误检查的难度，`因为如果在异步操作之后没有if (err != null)判断，就会报错`。

golang 方式处理报错有两个主要缺点:

1. `It is extremely repetitive. Typing if (err != null) every time you want to do something async puts you on the express lane to carpal tunnel.`
2. 它不能帮助您处理run()中的同步错误。
因此，golang 方式错误处理虽然是一种简洁的语法快捷方式，但是应该谨慎使用。跟try/catch对比并没有突出的优点。

### 在函数调用中使用 catch() 函数

try/catch()和Golang风格两种报错的处理方式都有它们的特点，但是最佳处理run()函数中所有报错的方法是使用run().catch()。换句话说，处理在调用函数时的所有报错而不是单独的某个报错。

```
run().
  catch(function handleError(err) {
    err.message; // Oops!
  }).
  // Handle any errors in `handleError()`. If the error handler
  // throws an error, kill the process.
  catch(err => { process.nextTick(() => { throw err; }) });

async function run() {
  await Promise.reject(new Error('Oops!'));
}
```

`Remember that async functions always return promises. This promise rejects if any uncaught error occurs in the function. If your async function body returns a promise that rejects, the returned promise will reject too.`

```
run().
  catch(function handleError(err) {
    err.message; // Oops!
  }).
  // Handle any errors in `handleError()`. If the error handler
  // throws an error, kill the process.
  catch(err => { process.nextTick(() => { throw err; }) });

async function run() {
  // Note that this is `return`, not `await`
  return Promise.reject(new Error('Oops!'));
}
```

为什么run().catch()比将整个run()函数体封装在try/catch中更方便用于处理错误处理程序中的错误。这是因为如果try/catch中的catch块也有可能抛出错误，这怎么办呢？惟一的解决方案是在catch块中再嵌套一个try/catch。

### 小贴士

一般来说，报错要么是可预期的，要么是意外的。在异步函数中，try/catch可以帮助您从预期的错误中优雅地恢复。但意外错误确实会发生，我们偶尔会得到一个意外的报错“TypeError: Cannot read property 'foo' of null”。

您应该在调用函数中处理异步函数中的意外错误。run()函数不应该负责处理所有可能的错误，而是应该运行().catch(handleError)来处理。
