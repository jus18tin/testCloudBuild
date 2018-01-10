using UnityEngine;
using UnityEngine.UI;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;

//広告枠IDの設定
[System.Serializable]
public class AdfurikunMovieRewardAdConfig {
	public string iPhoneAppID;//iOS
	public string androidAppID;//android
}

/**
アドフリくん動画リワードのGameObject(?)
 */
public class AdfurikunMovieRewardUtility : MonoBehaviour {

	public Action<String> onNotPrepared = null;
	public Action<String> onPrepareSuccess = null;
	public Action<String, String> onStartPlaying = null;
	public Action<String, String> onFinishPlaying = null;
	public Action<String, String> onFailedPlaying = null;
	public Action<String, String> onCloseAd = null;

	/// <summary>
	/// 状態の定義
	/// </summary>
	public enum ADF_MovieStatus
	{
		/// <summary>
		/// 準備が未完了
		/// </summary>
		NotPrepared,
		/// <summary>
		/// 準備完了
		/// </summary>
		PrepareSuccess,
		/// <summary>
		/// 再生開始
		/// </summary>
		StartPlaying,
		/// <summary>
		/// 再生完了
		/// </summary>
		FinishedPlaying,
		/// <summary>
		/// 再生失敗
		/// </summary>
		FailedPlaying,
		/// <summary>
		///  動画を閉じた
		/// </summary>
		AdClose
	}

	//広告枠IDの設定
	public AdfurikunMovieRewardAdConfig config;

	private static AdfurikunMovieRewardUtility mInstance = null;
	private GameObject mMovieRewardSrcObject = null;
	#if UNITY_ANDROID
	private AdfurikunUnityListener mAdfurikunUnityListener = null;
	#endif

	#if UNITY_IPHONE
	[DllImport("__Internal")]
	private static extern void initializeMovieRewardIOS_(string appID);
	[DllImport("__Internal")]
	private static extern bool isPreparedMovieRewardIOS_(string appID);
	[DllImport("__Internal")]
	private static extern void playMovieRewardIOS_(string appID);
	[DllImport("__Internal")]
	private static extern void disposeIOS_();

	#elif UNITY_ANDROID
	#endif

	public static AdfurikunMovieRewardUtility instance
	{
		get
		{
			return mInstance;
		}
	}

	public void Awake ()
	{
		if (mInstance == null) {
			mInstance = this;
			DontDestroyOnLoad(gameObject);
		}
		else
		{
			Destroy(gameObject);
		}
	}

	public void OnDestroy ()
	{
		if (Application.isEditor) return;
		if (mInstance == this) {
		}
	}

	public void OnApplicationPause (bool pause) {
		if (Application.isEditor) return;

		#if UNITY_IPHONE
		#elif UNITY_ANDROID
		if (Application.platform == RuntimePlatform.Android)
		{
			if (pause) {
				this.callAndroidMovieRewardMethod("onPause");
			} else {
				this.callAndroidMovieRewardMethod("onResume");
			}
		}
		#endif
	}

	public void Start()
	{
		if (Application.isEditor) return;
		this.initializeMovieReward();
	}

	public void initializeMovieReward(){
		this.initializeMovieReward(this.getAppID());
	}

	public void initializeMovieReward(string appId){
		if (!isValidAppID(appId)) {
			return;
		}
		#if UNITY_IPHONE
		if (Application.platform == RuntimePlatform.IPhonePlayer)
		{
			initializeMovieRewardIOS_(appId);
		}
		#elif UNITY_ANDROID
		if (Application.platform == RuntimePlatform.Android)
		{
			//動画リワード
			AndroidJavaClass player = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
			AndroidJavaObject activity = player.GetStatic<AndroidJavaObject>("currentActivity");
			if (mAdfurikunUnityListener == null) {
				mAdfurikunUnityListener = new AdfurikunUnityListener();
			}
			this.makeInstance_AdfurikunMovieRewardController().CallStatic("initialize", activity, appId, mAdfurikunUnityListener);
		}
		#endif
	}

	public bool isPreparedMovieReward(){
		return this.isPreparedMovieReward(this.getAppID());
	}

	public bool isPreparedMovieReward(string appId)
	{
		if (!isValidAppID(appId)) {
			return false;
		}

		#if UNITY_IPHONE
		if (Application.platform == RuntimePlatform.IPhonePlayer)
		{
			return isPreparedMovieRewardIOS_(appId);
		}
		#elif UNITY_ANDROID
		if (Application.platform == RuntimePlatform.Android)
		{
			return this.makeInstance_AdfurikunMovieRewardController().CallStatic<bool>("isPrepared", appId);
		}
		#endif
		return false;
	}

	[Obsolete("Use Action delegate instead.")]
	public void setMovieRewardSrcObject(GameObject movieRewardSrcObject)
	{
		this.setMovieRewardSrcObject(movieRewardSrcObject, this.getAppID());
	}

	public void setMovieRewardSrcObject(GameObject movieRewardSrcObject, string appId)
	{
		if (!isValidAppID(appId)) {
			return;
		}
		this.mMovieRewardSrcObject = movieRewardSrcObject;
		if (this.isPreparedMovieReward (appId)) {
			this.onPrepareSuccess.NullSafe (appId);
			this.sendMessage (ADF_MovieStatus.PrepareSuccess, appId, "");
		}
	}

	public void playMovieReward(){
		this.playMovieReward (this.getAppID());
	}

	/// <summary>
	/// 動画広告を再生する
	/// </summary>
	public void playMovieReward(string appId)
	{
		if (!isValidAppID(appId)) {
			return;
		}

		#if UNITY_IPHONE
		if (Application.platform == RuntimePlatform.IPhonePlayer)
		{
			if (!isPreparedMovieReward (appId)) {
				this.onNotPrepared.NullSafe (appId);
				this.sendMessage (ADF_MovieStatus.NotPrepared, appId, "");
			}else{
				playMovieRewardIOS_(appId);
			}
		}
		#elif UNITY_ANDROID
		if (Application.platform == RuntimePlatform.Android)
		{
			if (!isPreparedMovieReward (appId)) {
				this.onNotPrepared.NullSafe (appId);
				this.sendMessage (ADF_MovieStatus.NotPrepared, appId, "");
			}else{
				//動画リワード
				this.makeInstance_AdfurikunMovieRewardController().CallStatic("play", appId);
			}
		}
		#endif
	}

	/**
	 * コールバック受け取りメソッド
	 * iOS
	 */
	public void MovieRewardCallback(string param_str){

		string[] splitParamRoot = param_str.Split(';');
		string stateName = splitParamRoot[0].Split(':')[1];
		string appID = splitParamRoot[1].Split(':')[1];
		string adNetworkKey = "";
		if (splitParamRoot.Length > 2) {
			adNetworkKey = splitParamRoot[2].Split(':')[1];
		}

		ADF_MovieStatus messageStateName;
		//状態に応じて分岐
		switch(stateName){
		case "PrepareSuccess":
			messageStateName = ADF_MovieStatus.PrepareSuccess;
			this.onPrepareSuccess.NullSafe (appID);
			break;
		case "StartPlaying":
			messageStateName = ADF_MovieStatus.StartPlaying;
			this.onStartPlaying.NullSafe (appID, adNetworkKey);
			break;
		case "FinishedPlaying":
			messageStateName = ADF_MovieStatus.FinishedPlaying;
			this.onFinishPlaying.NullSafe (appID, adNetworkKey);
			break;
		case "FailedPlaying":
			messageStateName = ADF_MovieStatus.FailedPlaying;
			this.onFailedPlaying.NullSafe (appID, adNetworkKey);
			break;
		case "AdClose":
			messageStateName = ADF_MovieStatus.AdClose;
			this.onCloseAd.NullSafe (appID, adNetworkKey);
			break;
		default:
			return;
		}
		this.sendMessage (messageStateName, appID, adNetworkKey);
	}

	/**
	 * コールバック受け取りメソッド
	 * Android
	 */
	public class AdfurikunUnityListener : AndroidJavaProxy{

		public AdfurikunUnityListener() : base("jp.tjkapp.adfurikunsdk.moviereward.UnityMovieListener"){

		}

		public void onPrepareSuccess(String appId){
			AdfurikunMovieRewardUtility.mInstance.onPrepareSuccess.NullSafe (appId);
			AdfurikunMovieRewardUtility.mInstance.sendMessage (ADF_MovieStatus.PrepareSuccess, appId, "");
		}

		public void onStartPlaying(String appId , String adnetworkKey){
			AdfurikunMovieRewardUtility.mInstance.onStartPlaying.NullSafe (appId, adnetworkKey);
			AdfurikunMovieRewardUtility.mInstance.sendMessage (ADF_MovieStatus.StartPlaying, appId, adnetworkKey);
		}

		public void onFinishedPlaying(String appId , String adnetworkKey){
			AdfurikunMovieRewardUtility.mInstance.onFinishPlaying.NullSafe (appId, adnetworkKey);
			AdfurikunMovieRewardUtility.mInstance.sendMessage (ADF_MovieStatus.FinishedPlaying, appId, adnetworkKey);
		}

		public void onFailedPlaying(String appId , String adnetworkKey){
			AdfurikunMovieRewardUtility.mInstance.onFailedPlaying.NullSafe (appId, adnetworkKey);
			AdfurikunMovieRewardUtility.mInstance.sendMessage (ADF_MovieStatus.FailedPlaying, appId, adnetworkKey);
		}

		public void onAdClose(String appId , String adnetworkKey){
			AdfurikunMovieRewardUtility.mInstance.onCloseAd.NullSafe (appId, adnetworkKey);
			AdfurikunMovieRewardUtility.mInstance.sendMessage (ADF_MovieStatus.AdClose, appId, adnetworkKey);
		}
	}

	public void sendMessage(ADF_MovieStatus status , String appId , String adnetworkKey){
		if (this.mMovieRewardSrcObject != null) {
			ArrayList arr = new ArrayList();
			arr.Add((int)status);
			arr.Add(appId);
			arr.Add(adnetworkKey);
			this.mMovieRewardSrcObject.SendMessage("MovieRewardCallback", arr);
		}
	}

	public void dispose(){
		this.disposeResource ();
	}

	public void disposeResource(){
		#if UNITY_IPHONE
		if (Application.platform == RuntimePlatform.IPhonePlayer)
		{
			disposeIOS_();
		}
		#elif UNITY_ANDROID
		if (Application.platform == RuntimePlatform.Android)
		{
			this.callAndroidMovieRewardMethod("onDestroy");
		}
		#endif
	}

	private string getAppID(){
		string appId = "";
		#if UNITY_IPHONE
		if (Application.platform == RuntimePlatform.IPhonePlayer)
		{
			appId = config.iPhoneAppID;
		}
		#elif UNITY_ANDROID
		if (Application.platform == RuntimePlatform.Android)
		{
			appId = config.androidAppID;
		}
		#endif
		return appId;
	}

	private bool isValidAppID(string appId){
		return Regex.IsMatch(appId, @"^[a-f0-9]{24}$");
	}

	#if UNITY_ANDROID
	private AndroidJavaClass makeInstance_AdfurikunMovieRewardController(){
		return new AndroidJavaClass("jp.tjkapp.adfurikunsdk.moviereward.AdfurikunMovieRewardController");
	}

	private void callAndroidMovieRewardMethod(string methodName){
		this.makeInstance_AdfurikunMovieRewardController().CallStatic(methodName);
	}
	#endif
}