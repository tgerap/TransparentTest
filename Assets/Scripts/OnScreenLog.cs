using System.Collections.Generic;
using UnityEngine;

public class OnScreenLog : MonoBehaviour
{
    static SortedDictionary<int, string> _log = new SortedDictionary<int, string>();

    static int fontSize = 24;

    private int m_FpsAccumulator = 0;
    const float fpsMeasurePeriod = 0.5f;
    private int m_CurrentFps;
    private float m_FpsNextPeriod = 0;

    static int _iIndex = 1000;
    public bool IsShowLog = false;
    private void Start()
    {
        m_FpsNextPeriod = Time.realtimeSinceStartup + fpsMeasurePeriod;
    }

    // Update is called once per frame
    void Update()
    {
        if (IsShowLog == false)
            return;

        ++m_FpsAccumulator;

        if (Time.realtimeSinceStartup > m_FpsNextPeriod)
        {
            m_CurrentFps = (int)(m_FpsAccumulator / fpsMeasurePeriod);
            m_FpsAccumulator = 0;
            m_FpsNextPeriod += fpsMeasurePeriod;
        }
    }

    void OnGUI()
    {
        if (IsShowLog == false)
            return;

        GUI.contentColor = Color.red;
        GUIStyle style = GUI.skin.GetStyle("Label");
        style.fontSize = fontSize;
        style.alignment = TextAnchor.UpperLeft;
        style.wordWrap = false;

        float startPos = 0;
        float height = 0;
        string logText = "";

        foreach (var s in _log)
        {
            logText += " " + s.Value;
            logText += "\n";

            height += style.lineHeight;
        }

        height += 6;

        GUI.Label(new Rect(0, startPos, Screen.width - 1, height), logText, style);

        // FPS 
        height = style.lineHeight + 4;
        GUI.Label(new Rect(Screen.width - 100, Screen.height - 100, Screen.width - 1, height), m_CurrentFps.ToString());
    }

    float GetHeight()
    {
        float value = 1280.0f / 720.0f;

        float max = (float)Screen.width * value;

        var pos = (float)Screen.height - max;

        return pos / 2;
    }

    public static void Clear()
    {
        _log.Clear();
    }
    public static void Add(int key, string msg)
    {
        if (_log.ContainsKey(key))
            _log[key] = msg;
        else
            _log.Add(key, msg);

        string cleaned = msg.Replace("\r", " ");
        cleaned = cleaned.Replace("\n", " ");

        System.Console.WriteLine("[APP] " + cleaned);
    }

    public static void Add(int key, string format, params object[] args)
    {
        if (_log.ContainsKey(key))
            _log[key] = string.Format(format, args);
        else
            _log.Add(key, string.Format(format, args));
    }


    public static void Add(string msg)
    {
        if (_log.ContainsKey(_iIndex))
            _log[_iIndex] = msg;
        else
            _log.Add(_iIndex, msg);

        string cleaned = msg.Replace("\r", " ");
        cleaned = cleaned.Replace("\n", " ");

        System.Console.WriteLine("[APP] " + cleaned);

        ++_iIndex;
    }

    public static void AddLine(int key)
    {
        if (_log.ContainsKey(key))
            _log[key] = "------------------------------------------------------------";
        else
            _log.Add(key, "------------------------------------------------------------");
    }
}
