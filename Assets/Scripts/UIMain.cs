using System.Collections;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class UIMain : MonoBehaviour
{
    [Space(20)]
    [SerializeField] private Button Button_Material1 = null;
    [SerializeField] private Button Button_Material2 = null;
    [SerializeField] private Button Button_Material3 = null;

    [Space(20)]
    [SerializeField] private Button Button_Material1_Imm = null;
    [SerializeField] private Button Button_Material2_Imm = null;
    [SerializeField] private Button Button_Material3_Imm = null;

    [Space(20)]
    [SerializeField] private Button Button_Place1 = null;
    [SerializeField] private Button Button_Place2 = null;
    [SerializeField] private Button Button_Place3 = null;
    [SerializeField] private Button Button_Place4 = null;
    [SerializeField] private Button Button_Place5 = null;

    [Space(20)]
    [SerializeField] private TextMeshProUGUI Text_Current = null;

    [Space(20)]
    public Transform PlaceRoot = null;

    [Space(20)]
    public Material Material1 = null;
    public Material Material2 = null;
    public Material Material3 = null;

    [Space(20)]
    public TransparentCollider TransparentCollider = null;
    public Transform PlayerTransform = null;

    private Coroutine _coTransparent = null;
    private Material _targetMaterial = null;
    private Material _currentMaterial = null;

    private float[] PlaceXArray = null;

    private static readonly int SHADER_PROPERTY_SURFACE = Shader.PropertyToID("_Surface");

    private void Start()
    {
        _targetMaterial = TransparentCollider.TransparentMaterial;
        _currentMaterial = _targetMaterial;

        PlaceXArray = new float[PlaceRoot.childCount];

        for (int i = 0; i < PlaceXArray.Length; ++i)
        {
            PlaceXArray[i] = PlaceRoot.GetChild(i).transform.position.x;
        }
    }


    private void OnEnable()
    {
        Button_Material1.onClick.AddListener(OnClicked_Button1);
        Button_Material2.onClick.AddListener(OnClicked_Button2);
        Button_Material3.onClick.AddListener(OnClicked_Button3);

        Button_Material1_Imm.onClick.AddListener(OnClicked_Button1_Imm);
        Button_Material2_Imm.onClick.AddListener(OnClicked_Button2_Imm);
        Button_Material3_Imm.onClick.AddListener(OnClicked_Button3_Imm);

        Button_Place1.onClick.AddListener(OnClicked_Place1);
        Button_Place2.onClick.AddListener(OnClicked_Place2);
        Button_Place3.onClick.AddListener(OnClicked_Place3);
        Button_Place4.onClick.AddListener(OnClicked_Place4);
        Button_Place5.onClick.AddListener(OnClicked_Place5);
    }

    private void OnDisable()
    {
        Button_Material1.onClick.RemoveListener(OnClicked_Button1);
        Button_Material2.onClick.RemoveListener(OnClicked_Button2);
        Button_Material3.onClick.RemoveListener(OnClicked_Button3);

        Button_Material1_Imm.onClick.RemoveListener(OnClicked_Button1_Imm);
        Button_Material2_Imm.onClick.RemoveListener(OnClicked_Button2_Imm);
        Button_Material3_Imm.onClick.RemoveListener(OnClicked_Button3_Imm);

        Button_Place1.onClick.RemoveListener(OnClicked_Place1);
        Button_Place2.onClick.RemoveListener(OnClicked_Place2);
        Button_Place3.onClick.RemoveListener(OnClicked_Place3);
        Button_Place4.onClick.RemoveListener(OnClicked_Place4);
        Button_Place5.onClick.RemoveListener(OnClicked_Place5);
    }

    private void Update()
    {
        if (TransparentCollider == null)
            return;

        if (_currentMaterial == null)
            return;

        Text_Current.text = _currentMaterial.name + " :: " + TransparentCollider._currentTransparency;

        OnScreenLog.Add(3, TransparentCollider.Renderer.materials[1].shader + " :: " + TransparentCollider.Renderer.materials[1].GetFloat(SHADER_PROPERTY_SURFACE));
    }

    private void OnClicked_Button1()
    {
        _coTransparent?.Stop(this);
        _coTransparent = null;

        _targetMaterial = Material1;

        _coTransparent = CoTransparent().Start(this);
    }

    private void OnClicked_Button2()
    {
        _coTransparent?.Stop(this);
        _coTransparent = null;

        _targetMaterial = Material2;

        _coTransparent = CoTransparent().Start(this);
    }

    private void OnClicked_Button3()
    {
        _coTransparent?.Stop(this);
        _coTransparent = null;

        _targetMaterial = Material3;

        _coTransparent = CoTransparent().Start(this);
    }

    private void OnClicked_Button1_Imm()
    {
        _currentMaterial = _targetMaterial = Material1;
        TransparentCollider.ChangeMaterial(Material1);
    }

    private void OnClicked_Button2_Imm()
    {
        _currentMaterial = _targetMaterial = Material2;
        TransparentCollider.ChangeMaterial(Material2);
    }

    private void OnClicked_Button3_Imm()
    {
        _currentMaterial = _targetMaterial = Material3;
        TransparentCollider.ChangeMaterial(Material3);
    }

    private IEnumerator CoTransparent()
    {
        TransparentCollider.EndTransparent();

        yield return new WaitForSeconds(0.6f);

        _currentMaterial = _targetMaterial;
        TransparentCollider.SetTargetMaterial(_targetMaterial);

        yield return new WaitForSeconds(0.5f);

        TransparentCollider.StartTransparent();
    }

    private void OnClicked_Place1()
    {
        var a = PlayerTransform.position;
        a.x = PlaceXArray[0];

        PlayerTransform.position = a;
    }

    private void OnClicked_Place2()
    {
        var a = PlayerTransform.position;
        a.x = PlaceXArray[1];

        PlayerTransform.position = a;
    }

    private void OnClicked_Place3()
    {
        var a = PlayerTransform.position;
        a.x = PlaceXArray[2];

        PlayerTransform.position = a;
    }

    private void OnClicked_Place4()
    {
        var a = PlayerTransform.position;
        a.x = PlaceXArray[3];

        PlayerTransform.position = a;
    }

    private void OnClicked_Place5()
    {
        var a = PlayerTransform.position;
        a.x = PlaceXArray[4];

        PlayerTransform.position = a;
    }
}
