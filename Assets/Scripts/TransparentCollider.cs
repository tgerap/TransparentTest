/**
* TransparentCollider.cs
* 작성자 : jeongmin-kim
* 작성일 : 2023-01-30 오후 1:35:49
*/

using System.Collections;
using UnityEngine;

[RequireComponent(typeof(Collider))]
public class TransparentCollider : MonoBehaviour
{
    public enum ETRANSPARENT_STATE
    {
        NONE,
        START,
        STAY,
        END,
    }

    public Material TransparentMaterial = null;

    private Color[] _transparencyColors;
    private static readonly int SHADER_PROPERTY_CASTSHADOWS = Shader.PropertyToID("Cast Shadows");
    private static readonly int SHADER_PROPERTY_SURFACE = Shader.PropertyToID("_Surface");
    private static readonly string SHADER_NAME = "RM2/Nature/RM2_Tree_Bark";
    private const float MAX_TRANSPARENT_VALUE = 1f;
    private const float MIN_TRANSPARENT_VALUE = 0.3f;

    public Renderer Renderer;
    private Material[] _originMaterials;
    private Shader _originShader;
    private Shader _transparentShader = null;

    private ETRANSPARENT_STATE _currentState = ETRANSPARENT_STATE.NONE;

    private Coroutine _coTransparent = null;

    [Header("[DURATION CONTROL]")]
    [SerializeField] private float _FadeOut_Duration = 0.3f;
    [SerializeField] private float _FadeIn_Duration = 0.55f;

    public float _currentTransparency = 1f;

    private void Awake()
    {
        _transparentShader = TransparentMaterial.shader;
        Renderer = GetComponentInChildren<Renderer>();

        _originMaterials = Renderer.sharedMaterials;
        _originShader = Renderer.sharedMaterial.shader;

        _transparencyColors = new Color[_originMaterials.Length];

        for (int i = 0; i < _originMaterials.Length; i++)
            _transparencyColors[i] = _originMaterials[i].color;
    }

    private void Update()
    {
        for (int i = 0; i < Renderer.materials.Length; i++)
        {
            OnScreenLog.Add(i, Renderer.materials[i].shader + " :: " + _transparencyColors[i] + " :: " + Renderer.materials[i].GetFloat(SHADER_PROPERTY_SURFACE));
        }
    }

    public void SetTargetMaterial(in Material InMaterial)
    {
        _transparentShader = InMaterial.shader;
        Renderer = GetComponentInChildren<Renderer>();
    }

    public void ChangeMaterial(in Material InMaterial)
    {
        _transparentShader = InMaterial.shader;

        Renderer.materials[0].shader = InMaterial.shader;
        Renderer.materials[0] = InMaterial;

        Renderer.materials[1].shader = InMaterial.shader;
        Renderer.materials[1] = InMaterial;
    }

    public void StartTransparent() => OnTransparent(ETRANSPARENT_STATE.START, _currentTransparency, MIN_TRANSPARENT_VALUE, _FadeOut_Duration);
    public void EndTransparent() => OnTransparent(ETRANSPARENT_STATE.END, _currentTransparency, MAX_TRANSPARENT_VALUE, _FadeIn_Duration);

    private void OnTransparent(ETRANSPARENT_STATE InState, float InStart, float InEnd, float InDuration)
    {
        if (Renderer == null)
            return;

        _currentState = InState;

        ChangeShader();

        _coTransparent?.Stop(this);
        _coTransparent = null;

        _coTransparent = CoTransparent(InState, InStart, InEnd, InDuration).Start(this);
    }

    private void ChangeShader()
    {
        foreach (var material in Renderer.materials)
        {
            material.SetFloat(SHADER_PROPERTY_CASTSHADOWS, 1f);
            material.SetFloat(SHADER_PROPERTY_SURFACE, 1f);
            material.shader = _transparentShader;
        }

    }

    private IEnumerator CoTransparent(ETRANSPARENT_STATE InState, float InStart, float InEnd, float InDuration)
    {
        var elapsedTime = 0f;

        while (elapsedTime < InDuration)
        {
            _currentTransparency = Mathf.Lerp(InStart, InEnd, elapsedTime / InDuration);

            for (int i = 0; i < Renderer.materials.Length; i++)
            {
                Renderer.materials[i].SetFloat(SHADER_PROPERTY_CASTSHADOWS, 1f);
                Renderer.materials[i].SetFloat(SHADER_PROPERTY_SURFACE, 1f);
                _transparencyColors[i].a = _currentTransparency;
                Renderer.materials[i].color = _transparencyColors[i];
            }

            elapsedTime += Time.deltaTime;

            yield return null;
        }

        for (int i = 0; i < Renderer.materials.Length; i++)
        {
            _transparencyColors[i].a = InEnd;
            Renderer.materials[i].color = _transparencyColors[i];
        }

        if (InState == ETRANSPARENT_STATE.END)
        {
            foreach (var material in Renderer.materials)
                material.shader = _originShader;

            Renderer.sharedMaterials = _originMaterials;
        }

        _coTransparent = null;
    }
}