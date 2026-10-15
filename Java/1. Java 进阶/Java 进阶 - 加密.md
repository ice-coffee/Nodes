[toc]
## Https 介绍

**1. 什么是Https**

HTTPS（全称：Hypertext Transfer Protocol over Secure Socket Layer），是以安全为目标的HTTP通道，简单讲是HTTP的安全版。即HTTP下加入SSL层，HTTPS的安全基础是SSL，因此加密的详细内容就需要SSL

**2. Https的作用**

* 内容加密 建立一个信息安全通道，来保证数据传输的安全；
* 身份认证 确认网站的真实性
* 数据完整性 防止内容被第三方冒充或者篡改

**3. Https的劣势**

* 对数据进行加解密决定了它比http慢

> 需要进行非对称的加解密，且需要三次握手。首次连接比较慢点，当然现在也有很多的优化。

> 出于安全考虑，浏览器不会在本地保存HTTPS缓存。实际上，只要在HTTP头中使用特定命令，HTTPS是可以缓存的。Firefox默认只在内存中缓存HTTPS。但是，只要头命令中有Cache-Control: Public，缓存就会被写到硬盘上。 IE只要http头允许就可以缓存https内容，缓存策略与是否使用HTTPS协议无关。

**4. HTTPS和HTTP的区别**

* https协议需要到CA申请证书。
* http是超文本传输协议，信息是明文传输；https 则是具有安全性的ssl加密传输协议。
* http和https使用的是完全不同的连接方式，用的端口也不一样，前者默认是80，后者默认是443。
* http的连接很简单，是无状态的；HTTPS协议是由SSL+HTTP协议构建的可进行加密传输、身份认证的网络协议，比http协议安全。

### Https 安全验证过程

**建立安全连接**：初始阶段，客户端和服务器使用非对称加密算法进行握手，协商对称密钥用于后续通信的加密和解密。这个过程通常包括以下步骤：

* 服务器将自己的公钥和证书发送给客户端。
* 客户端验证服务器的证书，并使用服务器的公钥加密一个对称密钥。
* 服务器使用私钥解密客户端发送的对称密钥。

**传输层数据加密**：一旦安全连接建立，客户端和服务器之间的数据传输就会使用对称加密算法，而非对称加密算法主要用于加密和传输对称密钥。

## 常用加密算法

### 对称加密

指的就是加、解密使用的同是一串密钥，所以被称做对称加密。对称加密只有一个密钥作为私钥。 常见的对称加密算法：`DES`，`AES`等。

### 非对称加密

非对称加密是指拥有一对不同的秘钥：公钥、私钥。公钥加密的信息，只有私钥才能解密。反之，私钥加密的信息，只有公钥才能解密。最常用的非对称加密算法：`RSA`。

#### 公钥和私钥
**`作用：`**

公钥用途：

* **加密**： 公钥主要用于加密数据。任何人都可以使用公钥对数据进行加密，但只有私钥持有者才能解密该数据。
* **验证数字签名**： 公钥用于验证数字签名的有效性。发送者使用私钥对消息进行签名，接收者使用公钥验证签名，确保消息的完整性和真实性。

私钥用途：

* **解密**： 私钥用于解密由公钥加密的数据。只有私钥持有者能够解密这些数据。
* **生成数字签名**： 私钥用于生成数字签名，确保消息的完整性和真实性。只有私钥持有者才能够生成与其公钥配对的数字签名。

**`原因：`**

**公钥的公开性**： 公钥是公开的，因为它用于加密和验证数字签名，这些操作是公开的过程。任何人都可以使用公钥进行加密，确保只有私钥持有者能够解密。同时，公钥用于验证数字签名，确保只有私钥持有者能够生成有效的签名。

**私钥的隐私性**： 私钥是保密的，因为它用于解密加密的数据和生成数字签名。私钥的安全性对于确保加密数据的机密性和数字签名的真实性至关重要。如果私钥泄露，攻击者可能会解密加密的数据或伪造数字签名，从而危及通信的安全性。

在非对称加密中，公钥和私钥的配对是由复杂的数学算法生成的，并且在正常情况下，通过公钥无法推导出私钥。这种数学关系确保了在公开公钥的情况下，私钥仍然是安全的。

#### 数字签名验证：
数字签名的生成过程：

1. **选择哈希算法**： 首先，选择一个合适的哈希算法，例如SHA-256。哈希算法将原始消息映射为一个固定长度的摘要。
2. **生成摘要**： 使用选定的哈希算法对原始消息进行哈希运算，生成消息的摘要（哈希值）。
3. **使用私钥加密**： 使用发送者的私钥对摘要进行加密。这个操作产生了数字签名。
4. **发送消息和数字签名**： 将原始消息和生成的数字签名发送给接收者。

数字签名验证过程如下：

1. **接收消息和数字签名**： 接收者收到原始消息和数字签名。
2. **使用公钥解密**： 使用发送者的公钥对数字签名进行解密，得到解密后的摘要。
3. **验证摘要**： 使用相同的哈希算法对原始消息计算摘要。
4. **比较摘要**： 将接收者计算的摘要与解密后的摘要进行比较。如果两者匹配，说明消息未被篡改。

### 不可逆加密算法

不可逆加密算法指数据经过加密后，不能还原成原来的数据。Android 支持的有`MD5`、`SHA`、`HMAC`等。

## 加密算法比较

* 对称加密算法 (加解密密钥相同)

| 名称 | 密钥长度 | 运算速度 | 安全性 | 资源消耗 |
| --- | --- | --- | --- | --- |
| DES | 56位 | 较快 | 低 | 中 |
| 3DES | 112位或168位 | 慢 | 中 | 高 |
| AES | 128、192、256位 | 快 | 高 | 低 |

* 非对称加密算法 (加密密钥和解密密钥不同)

| 名称 | 成熟度 | 安全性(取决于密钥长度) | 运算速度 | 资源消耗 |
| --- | --- | --- | --- | --- |
| RSA | 高 | 高 | 慢 | 高 |
| DSA | 高 | 高 | 慢 | 只能用于数字签名 |
| ECC | 低 | 高 | 快 | 低 |

* 散列算法

| 名称 | 安全性 | 速度 | 
| --- | --- | --- |
| SHA-1 | 高 | 慢 |
| MD5 | 中 | 快 |

* 对称与非对称算法比较

| 名称 | 秘钥管理 | 安全性 | 速度 |
| --- | --- | --- | --- |
| 对称算法 | 比较难,不适合互联网,一般用于内部系统 | 中 | 特快,适合大数据量的加解密处理 |
| 非对称算法 | 密钥容易管理 | 高 | 慢,适合小数据量加解密或数据签名 |

* 作用

| 算法 | 作用 |
| --- | --- |
| 对称加密算法 | 1. 数据加密 |
| 非对称加密算法 | 1. 数据加密；2. 数字签名校验  |
| 不可逆算法 | 1. 生成摘要 |

### 加密算法选择

1. 我们应该根据自己的使用特点来确定，由于非对称加密算法的运行速度比对称加密算法的速度慢很多，当我们需要加密大量的数据时，建议采用对称加密算法，提高加解密速度。
2. 对称加密算法不能实现签名，因此签名只能非对称算法。
3. 由于对称加密算法的密钥管理是一个复杂的过程，密钥的管理直接决定着他的安全性，因此当数据量很小时，我们可以考虑采用非对称加密算法。
4. 实际的操作方式：采用非对称加密算法管理对称算法的密钥，然后用对称加密算法加密数据，这样我们就集成了两类加密算法的优点，既实现了加密速度快的优点，又实现了安全方便管理密钥的优点。
5. 一般来说，密钥越长，运行的速度就越慢，应该根据的我们实际需要的安全级别来选择，一般来说，RSA建议采用1024位的数字，ECC建议采用160位，AES采用128为即可。

## 秘钥工具类

### AES

```java
package com.example.androiddemo;  

import java.security.SecureRandom;  
import javax.crypto.Cipher;  
import javax.crypto.KeyGenerator;  
import javax.crypto.SecretKey;  
import javax.crypto.spec.SecretKeySpec;  
import android.annotation.SuppressLint;  

@SuppressLint("TrulyRandom")  
public class AESUtil {  

	private final static String HEX = "0123456789ABCDEF";  
	private final static int JELLY_BEAN_4_2 = 17;  


	public static String encrypt(String key, String src) throws Exception {  
	    byte[] rawKey = getRawKey(key.getBytes());  
	    byte[] result = encrypt(rawKey, src.getBytes());  
	    return toHex(result);  
	}  

	public static String decrypt(String key, String encrypted) throws Exception {  
	    byte[] rawKey = getRawKey(key.getBytes());  
	    byte[] enc = toByte(encrypted);  
	    byte[] result = decrypt(rawKey, enc);  
	    return new String(result);  
	}  

	@SuppressLint("TrulyRandom")  
	private static byte[] getRawKey(byte[] seed) throws Exception {  
	    KeyGenerator kgen = KeyGenerator.getInstance("AES");  
	    SecureRandom sr = null;  
	    // 在4.2以上版本中，SecureRandom获取方式发生了改变  
	    if (android.os.Build.VERSION.SDK_INT >= JELLY_BEAN_4_2) {  
	        sr = SecureRandom.getInstance("SHA1PRNG", "Crypto");  
	    } else {  
	        sr = SecureRandom.getInstance("SHA1PRNG");  
	    }  
	    sr.setSeed(seed);  
	    // 256 bits or 128 bits,192bits  
	    kgen.init(256, sr);  
	    SecretKey skey = kgen.generateKey();  
	    byte[] raw = skey.getEncoded();  
	    return raw;  
	}  

	private static byte[] encrypt(byte[] key, byte[] src) throws Exception {  
	    SecretKeySpec skeySpec = new SecretKeySpec(key, "AES");  
	    Cipher cipher = Cipher.getInstance("AES");  
	    cipher.init(Cipher.ENCRYPT_MODE, skeySpec);  
	    byte[] encrypted = cipher.doFinal(src);  
	    return encrypted;  
	}  

	private static byte[] decrypt(byte[] key, byte[] encrypted)  
	        throws Exception {  
	    SecretKeySpec skeySpec = new SecretKeySpec(key, "AES");  
	    Cipher cipher = Cipher.getInstance("AES");  
	    cipher.init(Cipher.DECRYPT_MODE, skeySpec);  
	    byte[] decrypted = cipher.doFinal(encrypted);  
	    return decrypted;  
	}  

	public static String toHex(String txt) {  
	    return toHex(txt.getBytes());  
	}  

	public static String fromHex(String hex) {  
	    return new String(toByte(hex));  
	}  

	public static byte[] toByte(String hexString) {  
	    int len = hexString.length() / 2;  
	    byte[] result = new byte[len];  
	    for (int i = 0; i < len; i++)  
	        result[i] = Integer.valueOf(hexString.substring(2 * i, 2 * i + 2),  
	                16).byteValue();  
	    return result;  
	}  

	public static String toHex(byte[] buf) {  
	    if (buf == null)  
	        return "";  
	    StringBuffer result = new StringBuffer(2 * buf.length);  
	    for (int i = 0; i < buf.length; i++) {  
	        appendHex(result, buf[i]);  
	    }  
	    return result.toString();  
	}  

	private static void appendHex(StringBuffer sb, byte b) {  
	    sb.append(HEX.charAt((b >> 4) & 0x0f)).append(HEX.charAt(b & 0x0f));  
	}  
}
```
