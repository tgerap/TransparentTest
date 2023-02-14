using UnityEngine;

[ExecuteAlways]
public class SpringArm : MonoBehaviour
{
    [Space]
    [Header("Follow Settings \n--------------------")]
    [Space]
    public Transform target;
    public float movementSmoothTime = 0.05f;
    public float targetArmLength = 3f;
    public Vector3 socketOffset;
    public Vector3 targetOffset;

    [Space]
    [Header("Rotation Settings \n-----------------------")]
    [Space]
    public bool useControlRotation = true;
    public float mouseSensitivity = 500f;

    #region Private Variables

    private Vector3 endPoint;
    private Vector3 socketPosition;

    // refs for SmoothDamping
    private Vector3 moveVelocity;
    private Vector3 collisionTestVelocity;

    // For mouse inputs
    private float pitch;
    private float yaw;
    #endregion


    private void Update()
    {
        if (Input.GetMouseButton(1) == false)
            return;

        // if target is null, return from here: NullReference check
        if (!target)
            return;

        // set the socketPosition
        SetSocketTransform();

        // handle mouse inputs for rotations
        if (useControlRotation && Application.isPlaying)
            Rotate();

        // follow the target applying targetOffset
        transform.position = Vector3.SmoothDamp(transform.position, target.position + targetOffset, ref moveVelocity, movementSmoothTime);
    }

    private void SetSocketTransform()
    {
        // Cache transform as it is used quite often
        Transform trans = transform;

        // offset a point in z direction of targetArmLength by socket offset and translating it into world space.
        Vector3 targetArmOffset = socketOffset - new Vector3(0, 0, targetArmLength);
        endPoint = trans.position + (trans.rotation * targetArmOffset);

        socketPosition = endPoint;

        // iterate through all children and set their position as socketPosition, using SmoothDamp to smoothly translate the vectors.
        foreach (Transform child in trans)
            child.position = Vector3.SmoothDamp(child.position, socketPosition, ref collisionTestVelocity, 0.2f);
    }

    private void Rotate()
    {
        // Increment yaw by Mouse X input
        yaw += Input.GetAxisRaw("Mouse X") * mouseSensitivity * Time.deltaTime;
        // Decrement pitch by Mouse Y input
        pitch -= Input.GetAxisRaw("Mouse Y") * mouseSensitivity * Time.deltaTime;
        // Clamp pitch so that we can't invert the the gameobject by mistake
        pitch = Mathf.Clamp(pitch, -90f, 90f);

        // Set the rotation to new rotation
        transform.localRotation = Quaternion.Euler(pitch, yaw, 0f);
    }
}
