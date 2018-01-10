#pragma strict
#pragma downcast

enum SCENE_STATE {
	MAIN,
	QUIT_WAIT,
	QUIT,
	END
}

private var sceneState : SCENE_STATE = SCENE_STATE.MAIN;
private var initialized : boolean = false;
private var logText : String = "";

private var rewardUtility : AdfurikunMovieRewardUtility = null;
private var interstitialUtility : AdfurikunMovieInterstitialUtility = null;
private var nativeAdViewUtility : AdfurikunMovieNativeAdViewUtility = null;

function Update () {
	if (!initialized) {
		initialized = true;
		var rewardObject : GameObject = GameObject.Find("AdfurikunMovieRewardUtility");
		var interstitialObject : GameObject = GameObject.Find("AdfurikunMovieInterstitialUtility");
		var nativeAdViewObject : GameObject = GameObject.Find("AdfurikunMovieNativeAdViewUtility");

		this.rewardUtility = rewardObject.GetComponent.<AdfurikunMovieRewardUtility>();
		this.interstitialUtility = interstitialObject.GetComponent.<AdfurikunMovieInterstitialUtility>();
		this.nativeAdViewUtility = nativeAdViewObject.GetComponent.<AdfurikunMovieNativeAdViewUtility>();

		//Set reward callbacks
		rewardUtility.onNotPrepared = this.onRewardNotPrepared;
		rewardUtility.onPrepareSuccess = this.onRewardPrepareSuccess;
		rewardUtility.onStartPlaying = this.onRewardStartPlaying;
		rewardUtility.onFinishPlaying = this.onRewardFinishPlaying;
		rewardUtility.onFailedPlaying = this.onRewardFailedPlaying;
		rewardUtility.onCloseAd = this.onRewardCloseAd;

		//Set interstitial callbacks
		interstitialUtility.onNotPrepared = this.onNotPrepared;
		interstitialUtility.onPrepareSuccess = this.onPrepareSuccess;
		interstitialUtility.onStartPlaying = this.onStartPlaying;
		interstitialUtility.onFinishPlaying = this.onFinishPlaying;
		interstitialUtility.onFailedPlaying = this.onFailedPlaying;
		interstitialUtility.onCloseAd = this.onCloseAd;

		//Set native ad callbacks
		nativeAdViewUtility.onLoadFinish = this.onLoadFinish;
		nativeAdViewUtility.onLoadError = this.onLoadError;
		nativeAdViewUtility.onPlayStart = this.onPlayStart;
		nativeAdViewUtility.onPlayFinish = this.onPlayFinish;
		nativeAdViewUtility.onPlayError = this.onPlayError;

		addLog("読込開始");
	}
	
	switch (this.sceneState) {
		case SCENE_STATE.MAIN:
			break;
		case SCENE_STATE.QUIT_WAIT:
			this.sceneState = SCENE_STATE.QUIT;
			break;
		case SCENE_STATE.QUIT:
			this.sceneState = SCENE_STATE.END;
			Application.Quit();
			break;
		case SCENE_STATE.END:
			break;
	}
}

function OnGUI () {
	var rewardObject : GameObject = GameObject.Find("AdfurikunMovieRewardUtility");
	var interstitialObject : GameObject = GameObject.Find("AdfurikunMovieInterstitialUtility");
	var nativeAdViewObject : GameObject = GameObject.Find("AdfurikunMovieNativeAdViewUtility");

	var rewardUtil : AdfurikunMovieRewardUtility = rewardObject.GetComponent.<AdfurikunMovieRewardUtility>();
	var interstitialUtil : AdfurikunMovieInterstitialUtility = interstitialObject.GetComponent.<AdfurikunMovieInterstitialUtility>();
	var nativeAdViewUtility : AdfurikunMovieNativeAdViewUtility = nativeAdViewObject.GetComponent.<AdfurikunMovieNativeAdViewUtility>();


	GUI.Label(Rect(2,2,580,40), "<size=24>AdfurikunMovieRewardSample</size>");

	if (GUI.Button(Rect(10,100,200,80), "<size=24>play reward</size>")) {
		rewardUtil.playMovieReward();
	}

	if (GUI.Button(Rect(10,200,200,80), "<size=24>play interstitial</size>")) {
		interstitialUtil.playMovieInterstitial();
	}

	var x: float; var y: float;
	var w: float; var h: float;
	var ratio = (9.0f / 16.0f);
	if (GUI.Button(Rect(10,300,200,80), "<size=24>load native</size>")) {
	    nativeAdViewUtility.loadMovieNativeAdView();
	    addLog("ネイティブ広告の読み込み開始");
	}

	if (GUI.Button(Rect(250,300,200,80), "<size=24>set native</size>")) {
		w = Screen.width * 0.5;
		h = w * ratio;
		x = (Screen.width - w);
		y = 0;
		nativeAdViewUtility.setMovieNativeAdView(x, y, w, h);
	    addLog("ネイティブ広告設置完了");
	}

	if (GUI.Button(Rect(500,300,200,80), "<size=24>hide native</size>")) {
	    nativeAdViewUtility.hideMovieNativeAdView();
	    addLog("ネイティブ広告非表示");
	}

	if (GUI.Button(Rect(10,400,200,80), "<size=24>play native</size>")) {
	    nativeAdViewUtility.playMovieNativeAdView();
	    addLog("ネイティブ広告再生");
	}

	if (GUI.Button(Rect(250,400,200,80), "<size=24>pause native</size>")) {
	    nativeAdViewUtility.pauseMovieNativeAdView();
	    addLog("ネイティブ広告停止");
	}

	if (GUI.Button(Rect(500,400,200,80), "<size=24>stop autoreload</size>")) {
	    nativeAdViewUtility.stopAutoReload();
	    addLog("ネイティブ広告の自動読み込み停止");
	}

	if (GUI.Button(Rect(750,400,200,80), "<size=24>start autoreload</size>")) {
	    nativeAdViewUtility.startAutoReload();
	    addLog("ネイティブ広告の自動読み込み開始");
	}

	var tvTexture: GameObject = GameObject.Find("TVTexture");
	if (GUI.Button(Rect(10,500,200,80), "<size=24>move native</size>")) {
		var padding = 10;
		w = tvTexture.GetComponent(typeof(RectTransform)).rect.width - (padding * 2);
		h = tvTexture.GetComponent(typeof(RectTransform)).rect.height - (padding * 2);
		x = tvTexture.transform.position.x - (w / 2);
		y = Screen.height - (tvTexture.transform.position.y + (h / 2));
		nativeAdViewUtility.setMovieNativeAdViewFrame(x, y, w, h - (padding * 2));
		addLog("ネイティブ広告の座標変更");
	}

	var g : GUIStyle = new GUIStyle();
	g.fontSize = 24;
	g.alignment = TextAnchor.UpperLeft;
	g.normal.textColor = Color.white;

	var boxHeight = Screen.height / 4;
	var logRect: Rect = UnityEngine.Rect(0, Screen.height - boxHeight, Screen.width, boxHeight);
	GUI.Box(logRect, "");
	GUI.Box(logRect, logText, g);

	//TV
	var newWidth = Screen.width * 0.5;
	var curWidth = tvTexture.GetComponent(typeof(RectTransform)).sizeDelta.x;
	var curHeight = tvTexture.GetComponent(typeof(RectTransform)).sizeDelta.y;
	var newHeight = curHeight * (newWidth / curWidth);
	tvTexture.GetComponent(typeof(RectTransform)).sizeDelta = new Vector2(newWidth, newHeight);

	var tmp: Vector3 = tvTexture.transform.position;
	tvTexture.transform.position = new Vector3(
		((Screen.width - newWidth) / 2),
		boxHeight + (newHeight / 2),
		tmp.z
	);
}

// -------------------------------
// 動画リワードCallBack
// -------------------------------
function onRewardNotPrepared(appID:String)
{
	addLog(appID +":準備が未完了");
}
function onRewardPrepareSuccess(appID:String)
{
	addLog(appID +":準備完了");
}
function onRewardStartPlaying(appID:String, adnetworkKey:String)
{
	addLog(appID +":再生開始(" + adnetworkKey + ")");
}
function onRewardFinishPlaying(appID:String, adnetworkKey:String)
{
	addLog(appID +":再生完了");
}
function onRewardFailedPlaying(appID:String, adnetworkKey:String)
{
	addLog(appID +":再生失敗");
}
function onRewardCloseAd(appID:String, adnetworkKey:String)
{
	addLog(appID +":動画を閉じた");
}

// -------------------------------
// 動画インタースティシャルCallBack
// -------------------------------
function onNotPrepared(appID:String)
{
	addLog(appID +":インタースティシャル準備が未完了");
}
function onPrepareSuccess(appID:String)
{
	addLog(appID +":インタースティシャル準備完了");
}
function onStartPlaying(appID:String, adnetworkKey:String)
{
	addLog(appID +":インタースティシャル再生開始(" + adnetworkKey + ")");
}
function onFinishPlaying(appID:String, adnetworkKey:String)
{
	addLog(appID +":インタースティシャル再生完了");
}
function onFailedPlaying(appID:String, adnetworkKey:String)
{
	addLog(appID +":インタースティシャル再生失敗");
}
function onCloseAd(appID:String, adnetworkKey:String)
{
	addLog(appID +":インタースティシャル動画を閉じた");
}

// -------------------------------
// 動画Native Ad View CallBack
// -------------------------------
function onLoadFinish(appID:String)
{
	addLog(appID +":ネイティブ広告の読み込み成功");
}
function onLoadError(appID:String, errorCode:String)
{
	addLog(appID +":ネイティブ広告の読み込み失敗, エラーコード:" + errorCode);
}

function onPlayStart(appID:String)
{
	addLog(appID +":ネイティブ広告の再生開始");
}

function onPlayFinish(appID:String, isVideo:System.Boolean)
{
	addLog(appID +":ネイティブ広告の再生完了, isVideo:" +isVideo);
}

function onPlayError(appID:String, errorCode:String)
{
	addLog(appID +":ネイティブ広告の再生失敗, エラーコード:" + errorCode);
}

private function addLog(str){
	logText = "<size=18>" + System.DateTime.Now.ToString("HH:mm:ss: ")  + str + "</size>\n" + logText;
}