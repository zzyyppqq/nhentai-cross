import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:nhentai/basic/entities/entities.dart';

const nHentai = NHentai._();

class NHentai {
  const NHentai._();

  static const _channel = MethodChannel("nhentai");

  /// 平铺调用, 为了直接与golang进行通信
  Future<String> _flatInvoke(String method, dynamic params) async {
    return await _channel.invokeMethod("flatInvoke", {
      "method": method,
      "params": params is String ? params : jsonEncode(params),
    });
  }

  /// 设置代理
  Future setProxy(String proxyUrl) {
    return _flatInvoke("setProxy", proxyUrl);
  }

  /// 获取代理
  Future<String> getProxy() {
    return _flatInvoke("getProxy", "");
  }

  /// 获取漫画
  Future<ComicPageData> comics(int page) async {
    return ComicPageData.fromJson(
      jsonDecode(await _flatInvoke("comics", "$page")),
    );
  }

  /// 获取漫画
  Future<ComicPageData> comicsByTagName(String tagName, int page) async {
    return ComicPageData.fromJson(jsonDecode(
      await _flatInvoke("comicsByTagName", {
        "tag_name": tagName,
        "page": page,
      }),
    ));
  }

  /// 获取漫画
  Future<ComicPageData> comicsBySearchRaw(String raw, int page) async {
    // 调用go获取漫画
    return ComicPageData.fromJson(jsonDecode(
      await _flatInvoke("comicsBySearchRaw", {
        "raw": raw,
        "page": page,
      }),
    ));
  }

  /// 漫画详情
  Future<ComicInfo> comicInfo(int comicId) async {
    return ComicInfo.formJson(jsonDecode(
      await _flatInvoke("comicInfo", "$comicId"),
    ));
  }

  /// 加载图片 (返回路径)
  Future<String> cacheImageByUrlPath(String url) async {
    return await _flatInvoke("cacheImageByUrlPath", url);
  }

  /// 手机端保存图片
  Future saveFileToImage(String path) async {
    return _channel.invokeMethod("saveFileToImage", {
      "path": path,
    });
  }

  /// 桌面端保存图片
  Future convertImageToJPEG100(String path, String dir) async {
    return _flatInvoke("convertImageToJPEG100", {
      "path": path,
      "dir": dir,
    });
  }

  /// 安卓版本号
  Future<int> androidVersion() async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod("androidVersion", {});
    }
    return 0;
  }

  /// 读取配置文件
  Future<String> loadProperty(String propertyName, String defaultValue) async {
    return await _flatInvoke("loadProperty", {
      "name": propertyName,
      "defaultValue": defaultValue,
    });
  }

  /// 保存配置文件
  Future<dynamic> saveProperty(String propertyName, String value) {
    return _flatInvoke("saveProperty", {
      "name": propertyName,
      "value": value,
    });
  }

  /// 更新浏览记录 (打开详情页面时)
  Future<dynamic> saveViewInfo(ComicInfo info) {
    return _flatInvoke("saveViewInfo", info);
  }

  /// 更新浏览记录 (打开页面滚动时)
  Future<dynamic> saveViewIndex(ComicInfo info, int index) {
    return _flatInvoke("saveViewIndex", {
      "info": info,
      "index": index,
    });
  }

  /// 获取最后浏览的页数
  Future<int> loadLastViewIndexByComicId(int comicId) async {
    return int.parse(await _flatInvoke("loadLastViewIndexByComicId", comicId));
  }

  /// 创建一个下载
  Future<dynamic> downloadComic(ComicInfo comicInfo) {
    return _flatInvoke("downloadComic", comicInfo);
  }

  /// 检查有没有下载过
  Future<bool> hasDownload(int comicId) async {
    return "true" == await _flatInvoke("hasDownload", "$comicId");
  }

  /// 获取所有下载列表
  Future<List<DownloadComicInfo>> listDownloadComicInfo() async {
    return List.of(jsonDecode(await _flatInvoke("listDownloadComicInfo", "")))
        .map((e) => DownloadComicInfo.formJson(e))
        .toList()
        .cast<DownloadComicInfo>();
  }

  /// 删除一个下载
  Future<dynamic> downloadSetDelete(int comicId) async {
    return _flatInvoke("downloadSetDelete", "$comicId");
  }

  /// HTTP-GET-STRING
  Future<String> httpGet(String url) async {
    return await _flatInvoke("httpGet", url);
  }

  Future setCookie(String cookies) async {
    return await _flatInvoke("setCookie", cookies);
  }

  Future setUserAgent(String s) async {
    return await _flatInvoke("setUserAgent", s);
  }
}
