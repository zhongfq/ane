package openane.alipay {
public class AlipayOrder {
    public var partner:String;
    public var seller:String;
    public var notifyURL:String;
    public var returnURL:String = "m.alipay.com";
    public var paymentType:String = "1";
    public var service:String = "mobile.securitypay.pay";
    public var itBPay:String = "30m";

    public var productName:String;
    public var productDescription:String;
    public var productPrice:String;
    public var productID:String;

    public function toString():String {
        var infos:Array = [];

        // 签约合作者身份ID
        append(infos, "partner", partner);

        // 签约卖家支付宝账号
        append(infos, "seller_id", seller);

        // 商户网站唯一订单号
        append(infos, "out_trade_no", productID);

        // 商品名称
        append(infos, "subject", productName);

        // 商品详情
        append(infos, "body", productDescription);

        // 商品金额
        append(infos, "total_fee", productPrice);

        // 服务器异步通知页面路径
        append(infos, "notify_url", notifyURL);

        // 服务接口名称，固定值
        append(infos, "service", service);

        // 支付类型，固定值
        append(infos, "payment_type", paymentType);

        // 参数编码，固定值
        append(infos, "_input_charset", "utf-8");

        // 设置未付款交易的超时时间
        // 默认30分钟，一旦超时，该笔交易就会自动被关闭。
        // 取值范围：1m～15d。
        // m-分钟，h-小时，d-天，1c-当天（无论交易何时创建，都在0点关闭）。
        // 该参数数值不接受小数点，如1.5h，可转换为90m。
        append(infos, "it_b_pay", itBPay);

        // 支付宝处理完请求后，当前页面跳转到商户指定页面的路径，可空
        append(infos, "return_url", returnURL);

        return infos.join("&");
    }

    private function append(infos:Array, key:String, value:String):void {
        infos.push(key + '="' + value + '"');
    }
}
}
