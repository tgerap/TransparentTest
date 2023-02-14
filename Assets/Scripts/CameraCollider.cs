/**
* CameraCollider.cs
* 작성자 : jeongmin-kim
* 작성일 : 2022-10-12 오후 2:16:34
*/

using System.Collections.Generic;
using System.Linq;
using Cinemachine;
using UnityEngine;

#if UNITY_EDITOR
using static UnityEditor.BaseShaderGUI;
#endif

[RequireComponent(typeof(BoxCollider))]
[RequireComponent(typeof(Rigidbody))]
public class CameraCollider : MonoBehaviour
{
    private BoxCollider _collider = null;
    private Rigidbody _rigidbody = null;


    public LayerMask _transparentLayerMask = 0;

    public bool IsDetectCollision { get; private set; } = false;

    public Dictionary<GameObject, TransparentCollider> TransparentLayerList { get; private set; } = null;

    public List<GameObject> Test = new();
    public List<GameObject> PullLayerList = null;

    public void Start()
    {
        _collider = gameObject.GetComponent<BoxCollider>();
        if (_collider == null)
            return;

        _collider.isTrigger = true;

        _rigidbody = gameObject.GetComponent<Rigidbody>();
        if (_rigidbody == null)
            return;

        _rigidbody.isKinematic = true;

        PullLayerList = new();
        TransparentLayerList = new();
    }

    public void SetColliderLength(float InLength)
    {
        var colliderCenter = _collider.center;
        colliderCenter.z = InLength * 0.5f;

        _collider.center = colliderCenter;

        var colliderSize = _collider.size;
        colliderSize.z = InLength;

        _collider.size = colliderSize;
    }

    private void OnTriggerEnter(Collider other)
    {
        if ((_transparentLayerMask.value & (1 << other.transform.gameObject.layer)) > 0)
            OnDetectEnterTransparentLayer(other);
    }

    private void OnTriggerExit(Collider other)
    {
        if ((_transparentLayerMask.value & (1 << other.transform.gameObject.layer)) > 0)
            OnDetectExitTransparentLayer(other);
    }

    private void OnDetectEnterTransparentLayer(Collider InCollider)
    {
        if (TransparentLayerList == null)
            return;

        if (Test.Contains(InCollider.gameObject) == false)
            Test.Add(InCollider.gameObject);

        if (TransparentLayerList.TryGetValue(InCollider.gameObject, out var outData) == true)
            return;

        var transparentCollider = InCollider.GetComponentInChildren<TransparentCollider>();
        if (transparentCollider == null)
            return;

        transparentCollider.StartTransparent();

        TransparentLayerList.Add(InCollider.gameObject, transparentCollider);
    }

    private void OnDetectExitTransparentLayer(Collider InCollider)
    {
        if (TransparentLayerList.TryGetValue(InCollider.gameObject, out var outData) == false)
            return;

        outData.EndTransparent();

        TransparentLayerList.Remove(InCollider.gameObject);
    }





}