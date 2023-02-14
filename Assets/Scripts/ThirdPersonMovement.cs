using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(CharacterController))]
public class ThirdPersonMovement : MonoBehaviour
{
    [SerializeField] protected float m_MoveSpeed = 5f;

    protected CharacterController m_Controller;
    protected Transform m_HandleTransform;

    protected Camera m_MainCamera;

    protected Vector3 m_MoveDirection;
    private float m_CurrentMoveSpeed = 0f;

    public Vector3 InputVector;

    protected virtual void Start()
    {
        m_Controller = GetComponent<CharacterController>();

        m_MainCamera = Camera.main;
        m_HandleTransform = transform;

    }
    // #if UNITY_EDITOR
    //     private void Update()
    //     {
    //         InputVector = new Vector3(Input.GetAxisRaw("Horizontal"), 0, Input.GetAxisRaw("Vertical")).normalized;
    //         if (InputVector.Equals(Vector2.zero) == true)
    //             m_CurrentMoveSpeed = 0f;
    //         else
    //             m_CurrentMoveSpeed = m_MoveSpeed;
    //     }
    // #endif

    // Update is called once per frame
    // private void LateUpdate()
    // {
    //     var h = InputVector.x;     //rot
    //     var v = InputVector.z;    //move

    //     Vector3 direction = new Vector3(h, 0, v);
    //     Vector3 forward = m_MainCamera.transform.TransformDirection(Vector3.forward);
    //     forward.y = 0;
    //     forward = forward.normalized;

    //     Vector3 right = new Vector3(forward.z, 0, -forward.x);

    //     m_MoveDirection = direction.x * right + direction.z * forward;

    //     m_MoveDirection.Normalize();
    //     m_MoveDirection = Vector3.ClampMagnitude(m_MoveDirection, 1.0f);

    //     m_Controller.Move(m_MoveDirection * m_MoveSpeed * Time.deltaTime);

    //     InputVector = Vector3.zero;
    // }

    public void UpdatePosition(in Vector3 InPosition)
    {
        if (m_Controller is null)
            return;

        m_Controller.enabled = false;
        transform.position = InPosition;
        m_Controller.enabled = true;
    }
}
